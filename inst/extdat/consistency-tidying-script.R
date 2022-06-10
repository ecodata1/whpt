library(tidyr)
library(dplyr)
library(purrr)
library(rlang)
library(utils)
library(readr)

data <- consistency_input
# Remove rows with missing data missing
data[data == ""] <- NA
data[data == "#N/A"] <- NA
data <- na.omit(data)

data <- data %>%  pivot_longer(cols = c("Typical ASPT Class","Typical NTAXA Class"), names_to = "metrics")

data$predicted <- NA
data$predicted[data$metrics == "Typical ASPT Class"] <- data$`Reference ASPT`[data$metrics == "Typical ASPT Class"]
data$predicted[data$metrics == "Typical NTAXA Class"] <- data$`Reference NTAXA`[data$metrics == "Typical NTAXA Class"]

data$observed <- NA
data$observed[data$metrics == "Typical ASPT Class"] <- data$`Reported ASPT`[data$metrics == "Typical ASPT Class"]
data$observed[data$metrics == "Typical NTAXA Class"] <- data$`Reported NTAXA`[data$metrics == "Typical NTAXA Class"]

data <- data %>%  rename("sample_id" = `loc code`,
                         "typical" = value,
                         "metric" = metrics
                         )

data <- data %>%  select(sample_id, typical, metric, predicted, observed)

data$metric[data$metric == "Typical ASPT Class"] <- "aspt"
data$metric[data$metric == "Typical NTAXA Class"] <- "ntaxa"
data$typical <- tolower(data$typical)

output <- consistency(data)


write.csv(output, file = "inst/extdat/consistency_assessment.csv" )
# data <- data.frame(
#   "sample_id" = c("1212","1212"),
#   "typical" = c("high","high"),
#   "metric" = c("aspt","ntaxa"),
#   "predicted" = c("6.333","12"),
#   "observed" = c("4.3","23")
# )
