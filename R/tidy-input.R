
tidy_input <- function(data = NULL) {

# data <- consistency_input
# Remove rows with missing data missing
data <- na.omit(data)

#  stop("These location(s) have rows missing values:", paste(data$`loc code`[!data$`loc code` %in% passing_data$`loc code`], " "))

data <- suppressWarnings(type.convert(data))
data <- data %>%  pivot_longer(cols = c("Typical ASPT Class","Typical NTAXA Class"), names_to = "metrics")

data$predicted <- data$predicted_response

ntaxa <- data[data$question == "WHPT NTAXA Abund" &
                data$index != "Reference ASPT" &
                data$metrics != "Typical ASPT Class", ]
aspt <- data[data$question == "WHPT ASPT Abund" &
               data$index != "Reference NTAXA" &
               data$metrics != "Typical NTAXA Class", ]
data <- bind_rows(ntaxa, aspt)
data <- data %>%  select(sample_id, value, metrics, predicted, response)
data <- data %>% rename(typical = value, observed = response, metric = metrics)

data$metric[data$metric == "Typical ASPT Class"] <- "aspt"
data$metric[data$metric == "Typical NTAXA Class"] <- "ntaxa"
data$typical <- tolower(data$typical)

return(data)

}
