test_that("whpts function works", {
  whpt_predictions <- whpt_predict(demo_data)
  expect_equal(class(whpt_predictions), c("grouped_df", "tbl_df", "tbl", "data.frame"))

  whpts <- whpts(demo_data)
  expect_equal(class(whpts), c("tbl_df", "tbl", "data.frame"))
  expect_equal(whpts$response[1], "7.13506455958832")
  expect_equal(whpts$response[2], "7.07582757084208")
  expect_equal(whpts$response[3], "19.7043660714286")
  expect_equal(whpts$response[4], "18.9529398549564")
  expect_equal(whpts$response[5], "As expected")
  expect_equal(whpts$response[6], "ntaxa")
  expect_equal(whpts$response[7], "No action required")
  expect_equal(whpts$response[8], "As expected")
  expect_equal(whpts$response[9], "neither")
  expect_equal(whpts$response[10], "No action required")

})
