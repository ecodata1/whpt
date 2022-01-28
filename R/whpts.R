#' Assess WHPT Consistency
#'
#' Assess if WHPT scores are consistent with expected classification.
#' @param data Dataframe
#'
#' @return Dataframe
#' @export
#'
#' @examples
#' results <- whpts(demo_data)
whpts <- function(data) {

  predictions <- whpt_predict(demo_data)
  data <- inner_join(demo_data, predictions, by = c("sample_id" = "sample_id"))
  assessments <- consistency(data)

}
