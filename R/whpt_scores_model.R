#' WHPT prediction model
#'
#' A data frame containing two models (ASPT and NTAXA). Contains a 'recipe' for
#' transforming data and the model to run.
#'
#' @format A data frame with 2 rows and 3 variables:
#' \describe{
#'   \item{DETERMINAND}{Value which is being predicted, either `ASPT` or `NTAXA`}
#'   \item{recipe}{This the 'recipe' to use to scale, center and transform data before applying model}
#'   \item{model_final}{This is the random forest model for predicting `ASPT` or `NTAXA`}

#' }
"whpt_scores_model"
