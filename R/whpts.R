#' Assess WHPT Consistency
#'
#' Assess if WHPT scores are consistent with expected classification.
#' @param data Dataframe
#' \describe{
#'   \item{location_id}{Location ID - unique identifer for location}
#'   \item{sample_id}{Sample ID - unique identifer for sample}
#'   \item{question}{Question - either `WHPT ASPT Abund` or `WHPT NTAXA Abund`}
#'   \item{response}{Response value to question}
#'   \item{NGR}{National Grid Reference - Great Britain only}
#'   \item{date_taken}{Date as character class in 2012-12-31 format only}
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
#'   \item{Reported WHPT Class Year}{Reported WHPT Class Year}
#'   \item{Typical ASPT Class}{Typical expected ASPT Class for this location}
#'   \item{Typical NTAXA Class}{Typical expected NTAXA Class for this location}
#'   \item{quality_element}{The type of element being assessed in this case 'River Invertebrates'}
#' }
#' @return Dataframe
#' \describe{
#'   \item{sample_id}{Sample ID - unique identifer for sample}
#'   \item{assessment}{Name of assessment completed - int this case 'assessment', 'driver' or 'action'}
#'   \item{value}{Associated value to the assessment column i.e. the output of the assessment}
#'   }
#' @importFrom dplyr inner_join
#' @export
#'
#' @examples
#' results <- whpts(demo_data)
whpts <- function(data) {
  predictions <- whpt_predict(demo_data)
  data <- inner_join(demo_data, predictions, by = c("sample_id" = "sample_id"))
  assessments <- consistency(data)

  return(assessments)

}
