# Compute Multivariate-Weighted CAMEL Index

Computes a composite year-on-year index for bank performance assessment
using the CAMEL framework. The multivariate weighting scheme employs
robust factor analysis to derive communality-based weights from the
correlation matrix of CAMEL ratios.

## Usage

``` r
camel_index(
  base_data,
  current_data,
  bank_names = NULL,
  n_factors = 3,
  scale_data = TRUE,
  cov_control = rrcov::CovControlOgk(),
  method = "pca",
  scores_method = "regression"
)
```

## Arguments

- base_data:

  A data frame or matrix containing the base year CAMEL ratios. If a
  data frame, the first column must contain bank identifiers (character
  or numeric). If a matrix, bank identifiers must be supplied separately
  via `bank_names`.

- current_data:

  A data frame or matrix containing the current year CAMEL ratios, in
  the same format and order as `base_data`.

- bank_names:

  A character or numeric vector of bank identifiers. Required when
  `base_data` and `current_data` are matrices. Must be the same length
  as the number of rows in the data. Ignored when inputs are data
  frames.

- n_factors:

  Integer specifying the number of factors to extract in the robust
  factor analysis. Default is `3`.

- scale_data:

  Logical indicating whether to standardize the data before factor
  analysis. Default is `TRUE`.

- cov_control:

  A control object for robust covariance estimation, passed to
  [`robustfa::FaCov()`](https://fbertran.github.io/robustfa/reference/FaCov.html).
  Default is
  [`rrcov::CovControlOgk()`](https://rdrr.io/pkg/rrcov/man/CovControlOgk.html).

- method:

  Character specifying the factor analysis method. Default is `"pca"`
  (principal component analysis). See
  [`robustfa::FaCov()`](https://fbertran.github.io/robustfa/reference/FaCov.html)
  for options.

- scores_method:

  Character specifying the method for computing factor scores. Default
  is `"regression"`. See
  [`robustfa::FaCov()`](https://fbertran.github.io/robustfa/reference/FaCov.html)
  for options.

## Value

A list of class `"camel_index"` containing:

- index_table:

  A
  [`tibble::tibble()`](https://tibble.tidyverse.org/reference/tibble.html)
  with columns `bank`, `I_mw` (composite index, base = 100), and `PD`
  (percentage difference from base).

- mw_lasp:

  Numeric vector of multivariate-weighted Laspeyres indices.

- mw_pash:

  Numeric vector of multivariate-weighted Paasche indices.

- I_mw:

  Numeric vector of composite indices (base = 100).

- PD:

  Numeric vector of percentage differences from base year.

- weights_base:

  Numeric vector of communality-based weights from base year factor
  analysis.

- weights_current:

  Numeric vector of communality-based weights from current year factor
  analysis.

- eigenvalues_base:

  Numeric vector of eigenvalues from base year correlation matrix.

- eigenvalues_current:

  Numeric vector of eigenvalues from current year correlation matrix.

- n_factors_base:

  Integer, number of eigenvalues \> 1 in base year.

- n_factors_current:

  Integer, number of eigenvalues \> 1 in current year.

- fa_base:

  The fitted
  [`robustfa::FaCov()`](https://fbertran.github.io/robustfa/reference/FaCov.html)
  object for base year.

- fa_current:

  The fitted
  [`robustfa::FaCov()`](https://fbertran.github.io/robustfa/reference/FaCov.html)
  object for current year.

- relativity_data:

  Matrix of current-to-base ratios for each CAMEL variable and bank.

- base_data:

  The processed base year data (matrix, no bank names).

- current_data:

  The processed current year data (matrix, no bank names).

- bank_names:

  Character vector of bank identifiers.

- n_factors:

  Integer, number of factors used.

- call:

  The matched call.

## Details

The index is computed as the arithmetic mean of two
multivariate-weighted Laspeyres-type and Paasche-type indices, scaled to
a base of 100. The percentage difference (PD) from the base year is also
reported.

## Data Format

When supplying data frames, the first column must be the bank identifier
(character or numeric), and the remaining columns must be the five CAMEL
ratios in the standard order:

1.  Capital Adequacy (Ca)

2.  Asset Quality (Aq) – inverted internally

3.  Management Efficiency (Me) – inverted internally

4.  Earnings (Eq)

5.  Liquidity (Lm) – inverted internally

The inversion of Aq, Me, and Lm is handled automatically because higher
values of these ratios indicate worse bank performance.

## Examples

``` r
# Using the built-in example data
base_year <- camel_2015
current_year <- camel_2022

result <- camel_index(base_year, current_year)
#> ℹ Using 3 factors (Kaiser criterion suggests 2 for base year).
result$index_table
#> # A tibble: 21 × 3
#>    bank      I_mw      PD
#>    <chr>    <dbl>   <dbl>
#>  1 Absa    116.    16.1  
#>  2 AB      327.   227.   
#>  3 ADB     154.    54.1  
#>  4 BA       99.6   -0.420
#>  5 CB        3.72 -96.3  
#>  6 Ecobank 549.   449.   
#>  7 FBN     171.    70.9  
#>  8 FB      151.    50.6  
#>  9 FAB     204.   104.   
#> 10 FNB     144.    43.7  
#> # ℹ 11 more rows

# Access individual components
result$mw_lasp
#>  [1]  1.17068455  3.24528378  1.52780746  0.98655880  0.01257239  6.02659502
#>  [7]  1.65444746  1.54951394  2.03302237  1.49816252  2.98825411  1.28723657
#> [13]  1.13849623 -1.97551778  0.82971916  0.84601356  0.94124611  1.70736177
#> [19]  1.43859304  0.28238957  1.40351131
result$mw_pash
#>  [1]  1.15082501  3.30155142  1.55371945  1.00501635  0.06177212  4.94882308
#>  [7]  1.76427243  1.46318577  2.05241470  1.37566218  2.51395785  1.28567395
#> [13]  1.14279086 -1.80089258  0.87655232  0.79703627  0.89022374  1.65663138
#> [19]  1.43712269  0.17659450  1.42483169
result$weights_base
#>        X1        X2        X3        X4        X5 
#> 0.7903609 0.7050024 0.8849089 0.8942996 0.8265737 

# Using matrices with explicit bank names
base_mat <- as.matrix(camel_2015[, -1])
curr_mat <- as.matrix(camel_2022[, -1])
banks <- camel_2015$Bank

result2 <- camel_index(base_mat, curr_mat, bank_names = banks)
#> ℹ Using 3 factors (Kaiser criterion suggests 2 for base year).
result2$index_table
#> # A tibble: 21 × 3
#>    bank      I_mw      PD
#>    <chr>    <dbl>   <dbl>
#>  1 Absa    116.    16.1  
#>  2 AB      327.   227.   
#>  3 ADB     154.    54.1  
#>  4 BA       99.6   -0.420
#>  5 CB        3.72 -96.3  
#>  6 Ecobank 549.   449.   
#>  7 FBN     171.    70.9  
#>  8 FB      151.    50.6  
#>  9 FAB     204.   104.   
#> 10 FNB     144.    43.7  
#> # ℹ 11 more rows
```
