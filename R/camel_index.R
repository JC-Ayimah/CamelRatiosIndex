#' Compute Multivariate-Weighted CAMEL Index
#'
#' Computes a composite year-on-year index for bank performance assessment using
#' the CAMEL framework. The multivariate weighting scheme employs robust factor
#' analysis to derive communality-based weights from the correlation matrix of
#' CAMEL ratios.
#'
#' The index is computed as the arithmetic mean of two multivariate-weighted
#' Laspeyres-type and Paasche-type indices, scaled to a base of 100. The
#' percentage difference (PD) from the base year is also reported.
#'
#' @param base_data A data frame or matrix containing the base year CAMEL ratios.
#'   If a data frame, the first column must contain bank identifiers (character or
#'   numeric). If a matrix, bank identifiers must be supplied separately via
#'   `bank_names`.
#' @param current_data A data frame or matrix containing the current year CAMEL
#'   ratios, in the same format and order as `base_data`.
#' @param bank_names A character or numeric vector of bank identifiers. Required
#'   when `base_data` and `current_data` are matrices. Must be the same length as
#'   the number of rows in the data. Ignored when inputs are data frames.
#' @param n_factors Integer specifying the number of factors to extract in the
#'   robust factor analysis. Default is `3`.
#' @param scale_data Logical indicating whether to standardize the data before
#'   factor analysis. Default is `TRUE`.
#' @param cov_control A control object for robust covariance estimation, passed to
#'   [robustfa::FaCov()]. Default is [rrcov::CovControlOgk()].
#' @param method Character specifying the factor analysis method. Default is
#'   `"pca"` (principal component analysis). See [robustfa::FaCov()] for options.
#' @param scores_method Character specifying the method for computing factor
#'   scores. Default is `"regression"`. See [robustfa::FaCov()] for options.
#'
#' @returns A list of class `"camel_index"` containing:
#' \describe{
#'   \item{index_table}{A [tibble::tibble()] with columns `bank`, `I_mw`
#'     (composite index, base = 100), and `PD` (percentage difference from base).}
#'   \item{mw_lasp}{Numeric vector of multivariate-weighted Laspeyres indices.}
#'   \item{mw_pash}{Numeric vector of multivariate-weighted Paasche indices.}
#'   \item{I_mw}{Numeric vector of composite indices (base = 100).}
#'   \item{PD}{Numeric vector of percentage differences from base year.}
#'   \item{weights_base}{Numeric vector of communality-based weights from
#'     base year factor analysis.}
#'   \item{weights_current}{Numeric vector of communality-based weights from
#'     current year factor analysis.}
#'   \item{eigenvalues_base}{Numeric vector of eigenvalues from base year
#'     correlation matrix.}
#'   \item{eigenvalues_current}{Numeric vector of eigenvalues from current year
#'     correlation matrix.}
#'   \item{n_factors_base}{Integer, number of eigenvalues > 1 in base year.}
#'   \item{n_factors_current}{Integer, number of eigenvalues > 1 in current year.}
#'   \item{fa_base}{The fitted [robustfa::FaCov()] object for base year.}
#'   \item{fa_current}{The fitted [robustfa::FaCov()] object for current year.}
#'   \item{relativity_data}{Matrix of current-to-base ratios for each CAMEL
#'     variable and bank.}
#'   \item{base_data}{The processed base year data (matrix, no bank names).}
#'   \item{current_data}{The processed current year data (matrix, no bank names).}
#'   \item{bank_names}{Character vector of bank identifiers.}
#'   \item{n_factors}{Integer, number of factors used.}
#'   \item{call}{The matched call.}
#' }
#'
#' @section Data Format:
#' When supplying data frames, the first column must be the bank identifier
#' (character or numeric), and the remaining columns must be the five CAMEL
#' ratios in the standard order:
#' 1. Capital Adequacy (Ca)
#' 2. Asset Quality (Aq) -- inverted internally
#' 3. Management Efficiency (Me) -- inverted internally
#' 4. Earnings (Eq)
#' 5. Liquidity (Lm) -- inverted internally
#'
#' The inversion of Aq, Me, and Lm is handled automatically because higher
#' values of these ratios indicate worse bank performance.
#'
#' @examples
#' # Using the built-in example data
#' base_year <- camel_2015
#' current_year <- camel_2022
#'
#' result <- camel_index(base_year, current_year)
#' result$index_table
#'
#' # Access individual components
#' result$mw_lasp
#' result$mw_pash
#' result$weights_base
#'
#' # Using matrices with explicit bank names
#' base_mat <- as.matrix(camel_2015[, -1])
#' curr_mat <- as.matrix(camel_2022[, -1])
#' banks <- camel_2015$Bank
#'
#' result2 <- camel_index(base_mat, curr_mat, bank_names = banks)
#' result2$index_table
#'
#' @export
camel_index <- function(base_data,
                        current_data,
                        bank_names = NULL,
                        n_factors = 3,
                        scale_data = TRUE,
                        cov_control = rrcov::CovControlOgk(),
                        method = "pca",
                        scores_method = "regression") {

  # Capture the call for the output object
  call <- match.call()

  # ---- Input validation and extraction ----
  base_list <- .extract_data(base_data, bank_names, arg_name = "base_data")
  current_list <- .extract_data(current_data, bank_names, arg_name = "current_data")

  base_mat <- base_list$data
  current_mat <- current_list$data
  banks <- base_list$names

  # Validate dimensions match
  if (!identical(dim(base_mat), dim(current_mat))) {
    cli::cli_abort(c(
      "Dimension mismatch between base and current data.",
      "i" = "base_data: {ncol(base_mat)} columns, {nrow(base_mat)} rows",
      "i" = "current_data: {ncol(current_mat)} columns, {nrow(current_mat)} rows"
    ))
  }

  if (nrow(base_mat) != length(banks)) {
    cli::cli_abort("Number of banks ({length(banks)}) does not match number of rows in data ({nrow(base_mat)}).")
  }

  # ---- Apply CAMEL transformations ----
  # Invert Aq (col 2), Me (col 3), Lm (col 5) because higher = worse
  base_mat <- .transform_camel(base_mat)
  current_mat <- .transform_camel(current_mat)

  # ---- Compute correlation matrices and eigenvalues ----
  cor_base <- stats::cor(base_mat)
  cor_current <- stats::cor(current_mat)

  ev_base <- eigen(cor_base)$values
  ev_current <- eigen(cor_current)$values

  n_factors_base <- sum(ev_base > 1)
  n_factors_current <- sum(ev_current > 1)

  # Warn if user-specified n_factors differs from Kaiser criterion
  if (n_factors != n_factors_base) {
    cli::cli_alert_info(
      "Using {n_factors} factors (Kaiser criterion suggests {n_factors_base} for base year)."
    )
  }

  # ---- Robust factor analysis ----
  if (scale_data) {
    base_scaled <- scale(base_mat)
    current_scaled <- scale(current_mat)
  } else {
    base_scaled <- base_mat
    current_scaled <- current_mat
  }

  fa_base <- robustfa::FaCov(
    x = base_scaled,
    factors = n_factors,
    cor = TRUE,
    cov.control = cov_control,
    method = method,
    scoresMethod = scores_method
  )

  fa_current <- robustfa::FaCov(
    x = current_scaled,
    factors = n_factors,
    cor = TRUE,
    cov.control = cov_control,
    method = method,
    scoresMethod = scores_method
  )

  # Extract communalities (weights)
  h_base <- fa_base@communality
  h_current <- fa_current@communality

  # ---- Compute multivariate-weighted indices ----
  relativity <- current_mat / base_mat

  # Laspeyres-type: base year weights
  mw_lasp <- apply(relativity, 1, stats::weighted.mean, w = h_base)

  # Paasche-type: current year weights
  mw_pash <- apply(relativity, 1, stats::weighted.mean, w = h_current)

  # Composite index (base = 100)
  I_mw <- round(abs((mw_lasp + mw_pash) / 2) * 100, 2)

  # Percentage difference from base
  PD <- I_mw - 100

  # ---- Build output ----
  index_table <- tibble::tibble(
    bank = banks,
    I_mw = I_mw,
    PD = PD
  )

  structure(list(
    index_table = index_table,
    mw_lasp = mw_lasp,
    mw_pash = mw_pash,
    I_mw = I_mw,
    PD = PD,
    weights_base = h_base,
    weights_current = h_current,
    eigenvalues_base = ev_base,
    eigenvalues_current = ev_current,
    n_factors_base = n_factors_base,
    n_factors_current = n_factors_current,
    fa_base = fa_base,
    fa_current = fa_current,
    relativity_data = relativity,
    base_data = base_mat,
    current_data = current_mat,
    bank_names = banks,
    n_factors = n_factors,
    call = call
  ), class = "camel_index")
}


# ---- Internal helper functions ----

#' Extract Data and Bank Names from Input
#'
#' Internal helper to handle both data frames and matrices.
#'
#' @param data Input data (data frame or matrix).
#' @param bank_names Optional bank names vector.
#' @param arg_name Name of the argument for error messages.
#' @returns List with `data` (numeric matrix, no bank names) and `names`.
#' @keywords internal
#' @noRd
.extract_data <- function(data, bank_names, arg_name) {
  if (is.data.frame(data)) {
    if (ncol(data) < 2) {
      cli::cli_abort("{arg_name} must have at least 2 columns (bank name + CAMEL ratios).")
    }

    names <- as.character(data[[1]])
    mat <- as.matrix(data[, -1, drop = FALSE])

    # If bank_names provided, validate and override
    if (!is.null(bank_names)) {
      if (length(bank_names) != nrow(data)) {
        cli::cli_abort("`bank_names` length ({length(bank_names)}) does not match {arg_name} rows ({nrow(data)}).")
      }
      names <- as.character(bank_names)
    }

  } else if (is.matrix(data)) {
    if (is.null(bank_names)) {
      cli::cli_abort(c(
        "`bank_names` is required when {arg_name} is a matrix.",
        "i" = "Supply a character or numeric vector of bank identifiers."
      ))
    }
    if (length(bank_names) != nrow(data)) {
      cli::cli_abort("`bank_names` length ({length(bank_names)}) does not match {arg_name} rows ({nrow(data)}).")
    }

    names <- as.character(bank_names)
    mat <- data

  } else {
    cli::cli_abort("{arg_name} must be a data frame or matrix.")
  }

  # Ensure numeric
  if (!is.numeric(mat)) {
    cli::cli_abort("CAMEL ratio columns in {arg_name} must be numeric.")
  }

  # Check for exactly 5 columns (standard CAMEL)
  if (ncol(mat) != 5) {
    cli::cli_alert_warning(
      "Expected 5 CAMEL ratio columns, but {arg_name} has {ncol(mat)}."
    )
  }

  list(data = mat, names = names)
}


#' Apply CAMEL Ratio Transformations
#'
#' Inverts Asset Quality (Aq), Management Efficiency (Me), and Liquidity (Lm)
#' because higher values indicate worse performance.
#'
#' @param mat Numeric matrix with CAMEL ratios in columns 1-5.
#' @returns Transformed matrix.
#' @keywords internal
#' @noRd
.transform_camel <- function(mat) {
  # Column 1: Capital Adequacy (Ca) -- keep as-is
  # Column 2: Asset Quality (Aq) -- invert
  # Column 3: Management Efficiency (Me) -- invert
  # Column 4: Earnings (Eq) -- keep as-is
  # Column 5: Liquidity (Lm) -- invert

  mat[, 2] <- 1 / (mat[, 2] * 100)  # Aq
  mat[, 3] <- 1 / (mat[, 3] * 100)  # Me
  mat[, 5] <- 1 / (mat[, 5] * 100)  # Lm

  mat
}
