#' Summary Method for camel_index Objects
#'
#' Provides a detailed summary of the CAMEL index computation, including
#' eigenvalues, factor loadings, and weight attribution.
#'
#' @param object An object of class `"camel_index"`.
#' @param ... Additional arguments (ignored).
#'
#' @returns Invisibly returns `object`.
#'
#' @examples
#' result <- camel_index(camel_2015, camel_2022)
#' summary(result)
#'
#' @export
summary.camel_index <- function(object, ...) {
  cli::cli_h1("CAMEL Index Summary")

  # Eigenvalue table
  cli::cli_h2("Eigenvalues (Base Year)")
  ev_base_df <- tibble::tibble(
    component = paste0("PC", seq_along(object$eigenvalues_base)),
    eigenvalue = round(object$eigenvalues_base, 4),
    variance_pct = round(object$eigenvalues_base / sum(object$eigenvalues_base) * 100, 2)
  )
  print(ev_base_df)

  cli::cli_h2("Eigenvalues (Current Year)")
  ev_current_df <- tibble::tibble(
    component = paste0("PC", seq_along(object$eigenvalues_current)),
    eigenvalue = round(object$eigenvalues_current, 4),
    variance_pct = round(object$eigenvalues_current / sum(object$eigenvalues_current) * 100, 2)
  )
  print(ev_current_df)

  # Factor loadings (if available)
  cli::cli_h2("Factor Loadings (Base Year)")
  loadings_base <- object$fa_base@loadings
  if (!is.null(loadings_base)) {
    loadings_df <- as.data.frame(loadings_base)
    loadings_df$ratio <- paste0("Ratio", seq_len(nrow(loadings_df)))
    loadings_df <- loadings_df[, c("ratio", setdiff(names(loadings_df), "ratio"))]
    print(tibble::as_tibble(loadings_df))
  }

  # Index distribution
  cli::cli_h2("Index Distribution")
  idx_summary <- tibble::tibble(
    statistic = c("Min", "Q1", "Median", "Mean", "Q3", "Max", "SD"),
    I_mw = c(
      min(object$I_mw),
      stats::quantile(object$I_mw, 0.25),
      stats::median(object$I_mw),
      mean(object$I_mw),
      stats::quantile(object$I_mw, 0.75),
      max(object$I_mw),
      stats::sd(object$I_mw)
    ),
    PD = c(
      min(object$PD),
      stats::quantile(object$PD, 0.25),
      stats::median(object$PD),
      mean(object$PD),
      stats::quantile(object$PD, 0.75),
      max(object$PD),
      stats::sd(object$PD)
    )
  )
  print(idx_summary)

  invisible(object)
}
