#' Print Method for camel_index Objects
#'
#' @param x An object of class `"camel_index"`.
#' @param ... Additional arguments (ignored).
#'
#' @returns Invisibly returns `x`.
#'
#' @examples
#' base_year <- camel_2015
#' current_year <- camel_2022
#'
#' result <- camel_index(base_year, current_year)
#' result
#'
#' @export
print.camel_index <- function(x, ...) {
  cli::cli_h1("CAMEL Index Results")

  cli::cli_text("Base year factor analysis: {x$n_factors_base} eigenvalue(s) > 1")
  cli::cli_text("Current year factor analysis: {x$n_factors_current} eigenvalue(s) > 1")
  cli::cli_text("Factors extracted: {x$n_factors}")

  cli::cli_h2("Index Table\n")
  print(x$index_table)

  cli::cli_h2("Communality Weights (Base Year)\n")
  weights_df <- tibble::tibble(
    ratio = paste0("Ratio", seq_along(x$weights_base)),
    weight = round(x$weights_base, 4)
  )
  print(weights_df)
  cat("\n")

  cli::cli_h2("Summary Statistics")
  cli::cli_text("Mean I_mw: {round(mean(x$I_mw), 2)}")
  cli::cli_text("Mean PD: {round(mean(x$PD), 2)}%")
  cli::cli_text("Best performing bank: {x$bank_names[which.max(x$PD)]} (PD = {max(x$PD)}%)")
  cli::cli_text("Worst performing bank: {x$bank_names[which.min(x$PD)]} (PD = {min(x$PD)}%)")
  cat("\n")

  invisible(x)
}
