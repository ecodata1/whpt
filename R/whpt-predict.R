#' Predict WHPT
#'
#' Run prediction for WHPT ASPT and NTAXA Based on whpt-metric-model -
#' using random forest / GIS predictors only based on RIVPACS reference dataset.
#' See `demo_data` for data structure / predictors required. Predictors
#' come from EA website:
#' https://environment.data.gov.uk/DefraDataDownload/?mapService=EA/RICT&mode=spatial
#'
#' @param data Data frame of `date_taken` and GIS based predictors with 14
#'   variables. Variable names can be lower or upper-case, and in any order.
#'   Extra variables can be present, these variables are ignored.
#' \describe{
#'   \item{sample_id}{Sample ID - unique identifer for sample}
#'   \item{date_taken}{Date as character class in `2012-12-31` format only}
#'   \item{ngr}{National Grid Reference - Great Britain only in `NT 00990 65767`
#'   format only}
#'   \item{altitude}{Altitude in metres}
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
#' }
#' @return Dataframe consisting of three variables sample_id, `index` and
#'   `predicted_response`.
#' \describe{
#'   \item{sample_id}{Sample ID - unique identifer for sample}
#'   \item{index}{Either `Reference ASPT` or `Reference NTAXA`)}
#'   \item{predicted_response}{Predicted response value}
#' }
#' @importFrom stats na.omit
#' @importFrom rlang .data
#' @importFrom lubridate month as_datetime
#' @importFrom tibble as_tibble
#' @importFrom dplyr select
#' @importFrom magrittr `%>%`
#' @importFrom tidyr unnest
#' @export
#'
#' @examples
#' predictions <- whpt_predict(demo_data)
whpt_predict <- function(data) {
  names(data) <- tolower(names(data))
  data <- select(
    data,
    .data$sample_id,
    .data$date_taken,
    .data$ngr,
    .data$altitude,
    .data$d_f_source,
    .data$logaltbar,
    .data$log_area,
    .data$disch_cat,
    .data$slope,
    .data$chalk,
    .data$clay,
    .data$hardrock,
    .data$limestone,
    .data$peat
    )
  # Only need unique rows data
  data <- unique(data)
  # Remove rows with missing data missing
  data[data == ""] <- NA
  data <- na.omit(data)
  if (nrow(data) < 1) {
    stop("Predictor variables for this site have not yet been configured,
         please contact Cathy Bennett or Tim Foster for help")
    return()
  }
  data <- as_tibble(data)

  # Rename to match training data in model
  data <- dplyr::rename(data,
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
  data$ngr <- trimws(data$ngr)
  data$ngr <- gsub(pattern = " ", replacement = "", x = data$ngr)
  # Calculate Lat and Lon
  wgs <- suppressWarnings(rict::osg_parse(data$ngr, coord_system = "WGS84"))
  data$latitude <- wgs$lat
  data$longitude <- wgs$lon

  # Convert date to datetime to match model/training data
  data <- as_tibble(data)
  data$date <- as_datetime(paste(data$date_taken, "00:00:00"))

  # Load models (ASPT & NTAXA)
  whpt_models <- whpt::whpt_scores_model

  # Add data as a list column for each model (ASPT & NTAXA)
  whpt_models$data <- list(data)

  # Bake function (to scale and center data etc. to match training data)
  baking <- function(recipe, data) {
    test_normalized <- recipes::bake(recipe,
      new_data = data,
      recipes::all_predictors()
    )
  }
  # Bake data (apply 'baking' function to scale and center data etc.)
  whpt_models <-
    dplyr::mutate(whpt_models,
      baked = purrr::map2(.data$recipe, .data$data, baking)
    )

  # Predict function
  model_predict <- function(baked, model) {
    test_results <- predict(model, baked)
    return(test_results)
  }

  # Predict
  whpt_models <-
    dplyr::mutate(whpt_models,
      predict = purrr::map2(.data$baked, .data$model_final, model_predict)
    )

  # Bind data with prediction
  whpt_models <-
    dplyr::mutate(whpt_models,
      data = purrr::map2(.data$data, .data$predict, dplyr::bind_cols)
    )

  # Pivot WHPT scores
  predict <- select(whpt_models, .data$DETERMINAND, data)
  predict <- unnest(predict, cols = c(.data$data))
  predict <- select(
    predict,
    .data$sample_id,
    .data$DETERMINAND,
    .data$.pred
  )
  names(predict) <- c("sample_id", "question", "response")
  predict$response <- round(predict$response, 2)
  predict$question[predict$question == "WHPT_ASPT"] <- "Reference ASPT"
  predict$question[predict$question == "WHPT_NTAXA"] <- "Reference NTAXA"

  return(predict)
}
