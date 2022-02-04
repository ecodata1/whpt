test_that("works", {
  whpt_predictions <- whpt_predict(demo_data)
  expect_equal(class(whpt_predictions), c("grouped_df", "tbl_df", "tbl", "data.frame"))

  whpts <- whpts(demo_data)
  expect_equal(class(whpts), c("tbl_df", "tbl" , "data.frame"))
})
