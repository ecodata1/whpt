test_that("whpts function works", {
  whpt_predictions <- whpt_predict(demo_data)
  expect_equal(class(whpt_predictions), c("grouped_df",
                                          "tbl_df",
                                          "tbl",
                                          "data.frame"))

  whpts <- whpts(demo_data)
  expect_equal(class(whpts), c("tbl_df", "tbl", "data.frame"))
  expect_equal(whpts$response[2], "7.27")
  expect_equal(whpts$response[1], "19.03")
  expect_equal(whpts$response[3], "As expected")
  expect_equal(whpts$response[4], "neither")
  expect_equal(whpts$response[5], "No action required")

})
