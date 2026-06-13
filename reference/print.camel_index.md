# Print Method for camel_index Objects

Print Method for camel_index Objects

## Usage

``` r
# S3 method for class 'camel_index'
print(x, ...)
```

## Arguments

- x:

  An object of class `"camel_index"`.

- ...:

  Additional arguments (ignored).

## Value

Invisibly returns `x`.

## Examples

``` r
base_year <- camel_2015
current_year <- camel_2022

result <- camel_index(base_year, current_year)
#> ℹ Using 3 factors (Kaiser criterion suggests 2 for base year).
result
#> 
#> ── CAMEL Index Results ─────────────────────────────────────────────────────────
#> Base year factor analysis: 2 eigenvalue(s) > 1
#> Current year factor analysis: 2 eigenvalue(s) > 1
#> Factors extracted: 3
#> 
#> ── Index Table ──
#> 
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
#> ── Communality Weights (Base Year) ──
#> 
#> # A tibble: 5 × 2
#>   ratio  weight
#>   <chr>   <dbl>
#> 1 Ratio1  0.790
#> 2 Ratio2  0.705
#> 3 Ratio3  0.885
#> 4 Ratio4  0.894
#> 5 Ratio5  0.827
#> 
#> ── Summary Statistics ──
#> 
#> Mean I_mw: 160.05
#> Mean PD: 60.05%
#> Best performing bank: Ecobank (PD = 448.77%)
#> Worst performing bank: CB (PD = -96.28%)
#> 
```
