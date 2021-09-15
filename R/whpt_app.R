#' Open whpt assessment web app
#'
#' Open whpt assessment an interactive shiny web app.
#'
#' @details
#' \code{whpt_app()} opens interactive shiny app.
#'
#' Using the app:
#' \enumerate{
#'  \item Select your file (or download a template to fill out)
#'  \item Or select your location and add data, aspt, ntaxa.
#'  \item View and download results.
#'  \item
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
  appDir <- system.file("shiny_apps", "whptapp", package = "whpts")
  if (appDir == "") {
    stop("Could not find example directory. Try re-installing `whpt`.", call. = FALSE)
  }
  shiny::runApp(appDir, display.mode = "normal", launch.browser = T)
}
