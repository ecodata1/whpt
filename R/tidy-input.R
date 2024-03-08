#' @param data dataframe
#' @importFrom utils type.convert
#' @importFrom rlang .data
#' @importFrom dplyr select filter rename bind_cols arrange desc
#' @importFrom tidyr pivot_longer
#' @importFrom magrittr `%>%`
#' @return dataframe
tidy_input <- function(data = NULL) {
  # Rename and re-arrange data before comparing against consistency 'rules'
  data <- select(
    data,
    .data$sample_id,
    .data$date_taken,
    .data$question,
    .data$response,
    .data$`Reported WHPT Class Year`,
    .data$`Typical ASPT Class`,
    .data$`Typical NTAXA Class`
  )
  data$`Reported WHPT Class Year` <- as.character(data$`Reported WHPT Class Year`)
  data <- arrange(data, desc(.data$question))
  observed <- data %>% filter(.data$question %in% c(
    "WHPT NTAXA Abund",
    "WHPT ASPT Abund"
  ))
  observed <- select(observed, "observed" = .data$response, .data$sample_id)
  observed <- unique(observed)
  observed <- select(observed, .data$observed)
  typical <- data %>% filter(.data$question %in% c(
    "WHPT NTAXA Abund",
    "WHPT ASPT Abund"
  ))
  typical <- select(
    typical,
    .data$sample_id,
    .data$`Typical ASPT Class`,
    .data$`Typical NTAXA Class`
  )
  typical <- unique(typical)
  typical <- pivot_longer(typical,
    names_to = "metric",
    cols = c(
      .data$`Typical NTAXA Class`,
      .data$`Typical ASPT Class`
    ),
    values_to = "typical"
  )
  predictions <- data %>% filter(.data$question %in% c(
    "Reference NTAXA",
    "Reference ASPT"
  ))


  predictions <- pivot_longer(predictions,
                          names_to = "metric",
                          cols = c(
                            .data$`Typical NTAXA Class`,
                            .data$`Typical ASPT Class`
                          )
  )


  predictions <- select(predictions,
    "predicted" = .data$response,
    .data$sample_id
  )
  predictions <- unique(predictions)
  predictions <- select(predictions, .data$predicted)
  typical <- arrange(typical,desc(metric))
  # test <- dplyr::right_join(predictions, typical, by = join_by(sample_id))
  # test <- unique(test)
  data <- bind_cols(typical, observed, predictions)
  # Remove rows with missing data missing
  data <- na.omit(data)
  data$metric[data$metric == "Typical ASPT Class"] <- "aspt"
  data$metric[data$metric == "Typical NTAXA Class"] <- "ntaxa"
  data$typical <- tolower(data$typical)
  return(data)
}
