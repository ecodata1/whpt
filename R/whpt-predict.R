#' Predict WHPT
#'
#' Run prediction for WHPT ASPT and NTAXA Based on whpt-metric-model -
#' using random forest / GIS predictors only based on RIVPACS reference dataset
#' See `demo_data` for data structure / predictors required Predictors
#' come from EA website:
#' https://environment.data.gov.uk/DefraDataDownload/?mapService=EA/RICT&mode=spatial
#'
#' @param data Dataframe of GIS based predictors with 20 variables:
#' \describe{
#'   \item{location_id}{Location ID - unique identifer for location}
#'   \item{sample_id}{Sample ID - unique identifer for sample}
#'   \item{NGR}{National Grid Reference - Great Britain only}
#'   \item{Date}{Date as character class in 2012-12-31 format only}
#'   \item{date_taken}{Date as character class in 2012-12-31 format only}
#'   \item{SX}{Coordinated where GIS predictors come from}
#'   \item{SY}{Coordinated where GIS predictors come from}
#'   \item{EX}{Coordinated where GIS predictors queried}
#'   \item{EY}{Coordinated where GIS predictors queried}
#'   \item{Altitude}{Altitude in metres}
#'   \item{d_f_source}{Distance from source in metres}
#'   \item{logaltbar}{Log altitude in metres of catchment upstream}
#'   \item{log_area}{Log area of catchment upstream in km squared}
#'   \item{disch_cat}{Discharge category}
#'   \item{slope}{Slope in m / km}
#'   \item{chalk}{Proporation of chalk in catchment}
#'   \item{clay}{Proporation of clay in catchment}
#'   \item{hardrock}{Proporation of hardrock in catchment}
#'   \item{limestone}{Proporation of limestone in catchment}
#'   \item{peat}{Proporation of peat in catchment}
#'   \item{shape_Length}{Length of the river section represented in GIS layer}
#' }
#' @return Dataframe consisting of three columns sample_id, ASPT and NTAXA
#' \describe{
#'   \item{sample_id}{Sample ID - unique identifer for sample}
#'   \item{ASPT}{Predicted Average Score Per Taxa (WHPT Distinct families)}
#'   \item{NTAXA}{Predicted total number of scoring WHPT families}
#' }
#' @importFrom stats na.omit
#' @importFrom rlang .data
#' @importFrom lubridate month
#' @importFrom magrittr `%>%`
#' @export
#'
#' @examples
#' predictions <- whpt_predict(demo_data)
whpt_predict <- function(data) {

  # Remove rows with missing data missing
  data[data == ""] <- NA
  data <- na.omit(data)

  data <- tibble::as_tibble(data)

  # Rename to match training data in model
  data <- dplyr::rename(data,
    altitude = .data$Altitude,
    distance_from_source = .data$d_f_source,
    catchment_altitude = .data$logaltbar,
    area = .data$log_area,
    discharge_category = .data$disch_cat
  )

  # Correct units to match training data
  data$catchment_altitude <- data$catchment_altitude^10
  data$area <- data$area^10
  data$distance_from_source <- data$distance_from_source / 1000
  data$chalk <- data$chalk * 100
  data$clay <- data$clay * 100
  data$peat <- data$peat * 100
  data$hardrock <- data$hardrock * 100
  data$limestone <- data$limestone * 100
  # Format NGR
  data$NGR <- trimws(data$NGR)
  data$NGR <- gsub(pattern = " ", replacement = "", x = data$NGR)
  # Calculate Lat and Lon
  wgs <- suppressWarnings(rict::osg_parse(data$NGR, coord_system = "WGS84"))
  data$latitude <- wgs$lat
  data$longitude <- wgs$lon

  # Convert date to datetime to match model/training data
  data <- tibble::as_tibble(data)
  data$date <- lubridate::as_datetime(paste(data$date_taken, "00:00:00"))

  # Load models
  dataset <- whpts::whpt_scores_model

  # Remove observed value if present - not required for predictions
  data$value <- NA

  # Apply all data to each model (ASPT and NTAXA have separate models, this makes it easy to run all models)
  data_list <- lapply(dataset$DETERMINAND, function(model) {
    model <- gsub("_", " ", model)
    data <- data[grep(model , data$question), ]
    return(data)
  })
  dataset$data <- data_list

  # Bake function (to scale and center data etc. to match training data)
  baking <- function(recipe, data) {
    test_normalized <- recipes::bake(recipe, new_data = data, recipes::all_predictors())
  }
  # Bake data (apply 'baking' function to scale and center data etc.)
  dataset <-
    dplyr::mutate(dataset,
      baked = purrr::map2(.data$recipe, .data$data, baking)
    )

  # Predict function
  model_predict <- function(baked, model) {
    test_results <- predict(model, baked)
    return(test_results)
  }

  # Predict
  dataset <-
    dplyr::mutate(dataset,
      predict = purrr::map2(.data$baked, .data$model_final, model_predict)
    )

  # Bind data with prediction
  dataset <-
    dplyr::mutate(dataset,
      data = purrr::map2(.data$data, .data$predict, dplyr::bind_cols)
    )

  # Pivot WHPT scores
  predict <- dplyr::select(dataset, .data$DETERMINAND, data)
  predict <- tidyr::unnest(predict, cols = c(.data$data))
  predict <- dplyr::select(predict, .data$sample_id, .data$DETERMINAND, .data$.pred)
  names(predict) <- c("sample_id", "index", "predicted_response")

  predict$index[predict$index == "WHPT_ASPT"] <- "Reference ASPT"
  predict$index[predict$index == "WHPT_NTAXA"] <- "Reference NTAXA"


  # predict <- tidyr::pivot_wider(predict, names_from = .data$DETERMINAND, values_from = .data$.pred)

  return(predict)
}
