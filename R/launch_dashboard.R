#' Launch the CamelRatiosIndex Shiny Dashboard
#'
#' Opens an interactive Shiny dashboard for computing and visualising
#' multivariate-weighted CAMEL indices.
#'
#' @param ... Additional arguments passed to [shiny::runApp()].
#'
#' @returns A Shiny application object (invisibly).
#'
#' @examples
#' \dontrun{
#' launch_dashboard()
#'
#' # Launch on a specific port
#' launch_dashboard(port = 3838)
#' }
#'
#' @export
launch_dashboard <- function(...) {
  app_dir <- system.file("shiny", package = "CamelRatiosIndex")
  if (app_dir == "") {
    cli::cli_abort("Could not find Shiny app directory. Try reinstalling the package.")
  }
  shiny::runApp(app_dir, ...)
}
