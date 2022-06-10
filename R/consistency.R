#' Assess Consistency
#'
#' Assess observed WHPT scores against consistency rules taking into account the
#' expected class.
#'
#' @param data Dataframe
#' \describe{
#'   \item{location_id}{Location ID - unique identifer for location}
#'   \item{sample_id}{Sample ID - unique identifer for sample}
#'   \item{question}{Question - either `WHPT ASPT Abund` or `WHPT NTAXA Abund`}
#'   \item{response}{Response value to question}
#'   \item{NGR}{National Grid Reference - Great Britain only}
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
#'   \item{Reported WHPT Class Year}{Reported WHPT Class Year}
#'   \item{Typical ASPT Class}{Typical expected ASPT Class for this location}
#'   \item{Typical NTAXA Class}{Typical expected NTAXA Class for this location}
#'   \item{quality_element}{The type of element being assessed in this case 'River Invertebrates'}
#'   \item{index}{The index being predicted in this case 'Reference ASPT' or 'Reference NTAXA'}
#'   \item{predicted_response}{The predicted response in this case the predicted NTAXA and ASPT}
#' }
#' @return Dataframe provides three outputs in three columns:
#' \describe{
#'   \item{sample_id}{Sample ID - unique identifer for sample}
#'   \item{assessment}{Name of the three assessments completed: `assessment`,
#' `driver` and `action`. `assessment` identifies if the overall whpt result is
#' `Likely problem detected`, `Possible cause for concern`, `Better than
#' expected` or `As expected`. The `driver` identifies whether NTAXA, ASPT or
#' neither are driving the `assessment`. The `action` is the recommended action
#' to take: `No action required`, `Non-urgent discussion...`, `Urgent
#' discussion..`}
#'   \item{value}{Associated value to the assessment column i.e. the output of
#'   the assessment} }
#' @importFrom tidyr pivot_longer
#' @importFrom dplyr inner_join select
#' @importFrom purrr map_df
#' @importFrom rlang .data
#' @importFrom magrittr `%>%`
#' @export
#'
#' @examples
#' predictions <- whpt_predict(demo_data)
#' data <- merge(demo_data, predictions, by.x = "sample_id", by.y = "sample_id")
#' assessments <- consistency(data)
consistency <- function(data) {
  data <- tidy_input(data)
  # validate/format
  names(data) <- tolower(names(data))
  data$typical <- tolower(as.character(data$typical))
  data$metric <- tolower(as.character(data$metric))
  data$predicted <- as.numeric(data$predicted)
  data$observed <- as.numeric(data$observed)
  data$sample_id <- as.character(data$sample_id)
  data <- na.omit(data)

  # get rules
  #  rules <- read.csv("inst/extdat/consistency-rules.csv")
  rules <- utils::read.csv(system.file("extdat",
    "consistency-rules.csv",
    package = "whpt"
  ))


  # apply rules to observed/predicted values
  output <- map_df(1:nrow(data), function(row) {
    row <- data[row, ]
    rule <- rules[rules$typical_class == row$typical &
      rules$metric == row$metric, ]
    eqi <- row$observed / row$predicted
    cc <- cut(
      x = eqi,
      breaks = sort(c(-Inf, rule$oe[1:6], Inf)),
      right = FALSE,
      include.lowest = FALSE,
      labels = rev(c(rule$cc))
    )
    class <- rule$class[rule$cc == cc]
    row$eqi <- eqi
    row$class <- class
    assessment <- whpt::assessment
    row <- inner_join(row, assessment, by = c("class" = "class"))
    return(row)
  })

  # For each sample find max class
  output <- map_df(split(output, output$sample_id), function(sample) {
    if (sample$class[1] == sample$class[2]) {
      sample$driver <- "neither"
    } else {
      max <- max(sample$class)
      sample$driver <- sample$metric[sample$class == max]
    }

    if (sample$driver[1] == "neither") {
      sample <- sample[1, ]
    } else {
      sample <- sample[sample$class == max, ]
    }
    return(sample)
  })

  output <- output %>% select(.data$sample_id, .data$assessment, .data$driver, .data$action)
  output <- output %>% pivot_longer(!.data$sample_id, names_to = "assessment")

  return(output)
}
