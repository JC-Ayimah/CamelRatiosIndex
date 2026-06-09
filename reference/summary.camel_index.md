# Summary Method for camel_index Objects

Provides a detailed summary of the CAMEL index computation, including
eigenvalues, factor loadings, and weight attribution.

## Usage

``` r
# S3 method for class 'camel_index'
summary(object, ...)
```

## Arguments

- object:

  An object of class `"camel_index"`.

- ...:

  Additional arguments (ignored).

## Value

Invisibly returns `object`.

## Examples

``` r
result <- camel_index(camel_2015, camel_2022)
#> ℹ Using 3 factors (Kaiser criterion suggests 2 for base year).
summary(result)
#> 
#> ── CAMEL Index Summary ─────────────────────────────────────────────────────────
#> 
#> ── Eigenvalues (Base Year) ──
#> 
#> # A tibble: 5 × 3
#>   component eigenvalue variance_pct
#>   <chr>          <dbl>        <dbl>
#> 1 PC1            2.16         43.3 
#> 2 PC2            1.26         25.1 
#> 3 PC3            0.966        19.3 
#> 4 PC4            0.324         6.48
#> 5 PC5            0.291         5.83
#> ── Eigenvalues (Current Year) ──
#> 
#> # A tibble: 5 × 3
#>   component eigenvalue variance_pct
#>   <chr>          <dbl>        <dbl>
#> 1 PC1            2.06         41.1 
#> 2 PC2            1.43         28.7 
#> 3 PC3            0.788        15.8 
#> 4 PC4            0.524        10.5 
#> 5 PC5            0.199         3.97
#> ── Factor Loadings (Base Year) ──
#> 
#> # A tibble: 5 × 4
#>   ratio   Factor1  Factor2 Factor3
#>   <chr>     <dbl>    <dbl>   <dbl>
#> 1 Ratio1  0.835    0.0532    0.302
#> 2 Ratio2  0.766    0.00678  -0.343
#> 3 Ratio3 -0.162    0.920     0.114
#> 4 Ratio4 -0.00290  0.0102    0.946
#> 5 Ratio5 -0.469   -0.762     0.160
#> ── Index Distribution ──
#> 
#> # A tibble: 7 × 3
#>   statistic   I_mw      PD
#>   <chr>      <dbl>   <dbl>
#> 1 Min         3.72 -96.3  
#> 2 Q1         99.6   -0.420
#> 3 Median    144.    43.7  
#> 4 Mean      160.    60.1  
#> 5 Q3        171.    70.9  
#> 6 Max       549.   449.   
#> 7 SD        115.   115.   
```
