
tidy_input <- function(data = NULL) {

# data <- consistency_input
# Remove rows with missing data missing
data <- na.omit(data)

#  stop("These location(s) have rows missing values:", paste(data$`loc code`[!data$`loc code` %in% passing_data$`loc code`], " "))

data <- suppressWarnings(type.convert(data))

data <- data %>%  pivot_longer(cols = c("Typical ASPT Class","Typical NTAXA Class"), names_to = "metrics")

data$predicted <- NA
data$predicted[data$metrics == "Typical ASPT Class"] <- data$`Reference ASPT`[data$metrics == "Typical ASPT Class"]
data$predicted[data$metrics == "Typical NTAXA Class"] <- data$`Reference NTAXA`[data$metrics == "Typical NTAXA Class"]

data$observed <- NA
data$observed[data$metrics == "Typical ASPT Class"] <- data$`Reported ASPT`[data$metrics == "Typical ASPT Class"]
data$observed[data$metrics == "Typical NTAXA Class"] <- data$`Reported NTAXA`[data$metrics == "Typical NTAXA Class"]

data <- data %>%  rename(
                         "typical" = value,
                         "metric" = metrics
)

data <- data %>%  select(sample_id, typical, metric, predicted, observed)

data$metric[data$metric == "Typical ASPT Class"] <- "aspt"
data$metric[data$metric == "Typical NTAXA Class"] <- "ntaxa"
data$typical <- tolower(data$typical)

# output <- consistency(data)



return(data)

}
