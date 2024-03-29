% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/consistency.R
\name{consistency}
\alias{consistency}
\title{Assess Consistency}
\usage{
consistency(data)
}
\arguments{
\item{data}{Dataframe
\describe{
\item{location_id}{Location ID - unique identifer for location}
\item{sample_id}{Sample ID - unique identifer for sample}
\item{question}{Question - either \verb{WHPT ASPT Abund} or \verb{WHPT NTAXA Abund}}
\item{response}{Response value to question}
\item{NGR}{National Grid Reference - Great Britain only}
\item{date_taken}{Date as character class in 2012-12-31 format only}
\item{SX}{Coordinated where GIS predictors come from}
\item{SY}{Coordinated where GIS predictors come from}
\item{EX}{Coordinated where GIS predictors queried}
\item{EY}{Coordinated where GIS predictors queried}
\item{Altitude}{Altitude in metres}
\item{d_f_source}{Distance from source in metres}
\item{logaltbar}{Log altitude in metres of catchment upstream}
\item{log_area}{Log area of catchment upstream in km squared}
\item{disch_cat}{Discharge category}
\item{slope}{Slope in m / km}
\item{chalk}{Proporation of chalk in catchment}
\item{clay}{Proporation of clay in catchment}
\item{hardrock}{Proporation of hardrock in catchment}
\item{limestone}{Proporation of limestone in catchment}
\item{peat}{Proporation of peat in catchment}
\item{shape_Length}{Length of the river section represented in GIS layer}
\item{Reported WHPT Class Year}{Reported WHPT Class Year}
\item{Typical ASPT Class}{Typical expected ASPT Class for this location}
\item{Typical NTAXA Class}{Typical expected NTAXA Class for this location}
\item{quality_element}{The type of element being assessed in this case 'River Invertebrates'}
\item{index}{The index being predicted in this case 'Reference ASPT' or 'Reference NTAXA'}
\item{predicted_response}{The predicted response in this case the predicted NTAXA and ASPT}
}}
}
\value{
Dataframe provides three outputs in three columns:
\describe{
\item{sample_id}{Sample ID - unique identifer for sample}
\item{assessment}{Name of the three assessments completed: \code{assessment},
\code{driver} and \code{action}. \code{assessment} identifies if the overall whpt result is
\verb{Likely problem detected}, \verb{Possible cause for concern}, \verb{Better than expected} or \verb{As expected}. The \code{driver} identifies whether NTAXA, ASPT or
neither are driving the \code{assessment}. The \code{action} is the recommended action
to take: \verb{No action required}, \verb{Non-urgent discussion...}, \verb{Urgent discussion..}}
\item{value}{Associated value to the assessment column i.e. the output of
the assessment} }
}
\description{
Assess observed WHPT scores against consistency rules taking into account the
expected class.
}
\examples{
predictions <- whpt_predict(demo_data)
data <- dplyr::bind_rows(demo_data, predictions)
assessments <- consistency(data)
}
