#' Demo predictor data
#'
#'
#' @format A data frame with 286 rows and 20 variables:
#' \describe{
#'   \item{location_id}{Location ID - unique identifer for location}
#'   \item{NGR}{National Grid Reference - Great Britain only}
#'   \item{Date}{Date as character class in 2012-12-31 format only}
#'   \item{Sampled date}{Predicted total number of scoring WHPT families}
#'   \item{SX}{Coordinated where GIS predictors come from}
#'   \item{SY}{Coordinated where GIS predictors come from}
#'   \item{EX}{Coordinated where GIS predictors queried}
#'   \item{EY}{Coordinated where GIS predictors queried}
#'   \item{Altitude}{Altitude in metres}
#'   \item{d_f_source}{Distance from source in metres}
#'   \item{logaltbar}{Log altitude in metres of catchment upstream}
#'   \item{log_area}{Log area of catchment upstream in km squared}
#'   \item{disch_cat}{Discharge category}
#'   \item{slope}{Slope in m / km}
#'   \item{chalk}{Proporation of chalk in catchment}
#'   \item{clay}{Proporation of clay in catchment}
#'   \item{hardrock}{Proporation of hardrock in catchment}
#'   \item{limestone}{Proporation of limestone in catchment}
#'   \item{peat}{Proporation of peat in catchment}
#'   \item{shape_Length}{Length of the river section represented in GIS layer}
#' }
"demo_data"
