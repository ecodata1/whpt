# data <- data.frame(
#   "sample_id" = c("1212","1212"),
#   "typical" = c("high","high"),
#   "metric" = c("aspt","ntaxa"),
#   "predicted" = c("6.333","12"),
#   "observed" = c("4.3","23")
# )
#' @importFrom purrr map_df
#' @importFrom magrittr %>%
#' @importFrom dplyr inner_join select
#' @import utils read.csv
consistency <- function(data) {
  # validate/format
  names(data) <- tolower(names(data))
  data$typical <- tolower(as.character(data$typical))
  data$metric <- tolower(as.character(data$metric))
  data$predicted <- as.numeric(data$predicted)
  data$observed <- as.numeric(data$observed)
  data$sample_id <- as.character(data$sample_id)
  data <- na.omit(data)

  # get rules
  rules <- read.csv("inst/extdat/consistency-rules.csv")

  # apply rules to observed/predictec values
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

  output <- output %>% select(sample_id, assessment, driver, action)
  return(output)
}
