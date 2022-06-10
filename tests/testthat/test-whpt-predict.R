test_that("predict works", {
  data <- demo_data
  predictions <- whpt_predict(demo_data)


  # data <- utils::read.csv(system.file("extdat",
  #                                           "predictors.csv",
  #                                           package = "whpt"
  # ))
  #
  # data$sample_id <-   data$location_id
  # data$date_taken <- "2022-02-04"
  # data$question <-
  # whpt_predict(predictors)
})
