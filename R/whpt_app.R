#' Open RICT web app
#'
#' Open RICT as an interactive shiny web app.
#'
#' @details
#' \code{rict_app()} opens RICT as an interactive shiny app. RICT will
#' automatically detect if the input file contains NI or GB grid references and
#' apply the correct model including if GIS / geological predictors are used
#' (currently only available for GB).
#'
#' Using the app:
#' \enumerate{
#'  \item Select your required year type (multi/single) for classification and
#'  type of prediction for instance include taxa or all indices.
#'  \item Click the Browse for .csv file button to select and upload a data file.
#'  \item View and download results.
#'  }
#'
#' @examples
#' \dontrun{
#' whpt_app()
#' }
#'
#' @export whpt_app

whpt_app <- function() {
  message("This app is a work in progress")
  appDir <- system.file("shiny_apps", "whptapp", package = "whpt")
  if (appDir == "") {
    stop("Could not find example directory. Try re-installing `whpt`.", call. = FALSE)
  }
  shiny::runApp(appDir, display.mode = "normal", launch.browser = T)
}
