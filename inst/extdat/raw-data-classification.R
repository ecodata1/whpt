

library(readr)
library(tidyverse)
ntaxa_report <- read_csv("inst/extdat/ntaxa-classification-water-body.csv")
aspt_report <- read_csv("inst/extdat/aspt-classification-water-body.csv")

class_report <- bind_rows(ntaxa_report, aspt_report)

year_report <- pivot_longer(class_report,names_to = c("year"), cols = c(as.character(paste(2008:2018))))
year_report <- select(year_report, -ends_with("confidence"))
year_report$question <- "class"

confidence_report <- pivot_longer(class_report,names_to = "year", cols = as.character(paste0(2008:2018, "_confidence")))
confidence_report <- select(confidence_report, -ends_with(as.character(paste0(2008:2018))))
confidence_report$question <- "confidence"
confidence_report$year <- gsub(pattern = "_confidence" ,"", confidence_report$year)
report <- bind_rows(year_report, confidence_report)

report$year <- as.numeric(report$year)


filtered_report <- map_df(split(report, report$Location), function(id) {

  max_year <- max(id$year[id$question == 'class' & !is.na(id$value)])
  max_rows <- id[id$year == max_year,]
  return(max_rows)
})

filtered_report <- pivot_wider(filtered_report, names_from = question, values_from = value)

filtered_report <- pivot_wider(filtered_report, names_from = Parameter, values_from = c(class, confidence))

filtered_report <- rename(filtered_report,
                          "ASPT class" = `class_1-3-2-3-3-1: Macroinvertebrates (ASPT)`,
                          "NTAXA class" = `class_1-3-2-3-3-2: Macroinvertebrates (NTAXA)`,
                          "ASPT confidence" = `confidence_1-3-2-3-3-1: Macroinvertebrates (ASPT)`,
                          "NTAXA confidence" = `confidence_1-3-2-3-3-2: Macroinvertebrates (NTAXA)`)

write.csv(filtered_report, file='inst/extdat/typical-class.csv')
