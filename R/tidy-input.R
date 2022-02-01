#' @param data dataframe
#' @importFrom utils type.convert
#' @importFrom rlang .data
#' @return dataframe
tidy_input <- function(data = NULL) {

# data <- consistency_input
# Remove rows with missing data missing
data <- na.omit(data)

#  stop("These location(s) have rows missing values:", paste(data$`loc code`[!data$`loc code` %in% passing_data$`loc code`], " "))

data <- suppressWarnings(type.convert(data))
data <- tidyr::pivot_longer(data, cols = c("Typical ASPT Class","Typical NTAXA Class"), names_to = "metrics")

data$predicted <- data$predicted_response

ntaxa <- data[data$question == "WHPT NTAXA Abund" &
                data$index != "Reference ASPT" &
                data$metrics != "Typical ASPT Class", ]
aspt <- data[data$question == "WHPT ASPT Abund" &
               data$index != "Reference NTAXA" &
               data$metrics != "Typical NTAXA Class", ]
data <- dplyr::bind_rows(ntaxa, aspt)
data <- dplyr::select(data, .data$sample_id, .data$value, .data$metrics, .data$predicted, .data$response)
data <- dplyr::rename(data, typical = .data$value, observed = .data$response, metric = .data$metrics)

data$metric[data$metric == "Typical ASPT Class"] <- "aspt"
data$metric[data$metric == "Typical NTAXA Class"] <- "ntaxa"
data$typical <- tolower(data$typical)

return(data)

}
