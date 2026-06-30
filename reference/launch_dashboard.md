# Launch the CamelRatiosIndex Shiny Dashboard

Opens an interactive Shiny dashboard for computing and visualising
multivariate-weighted CAMEL indices.

## Usage

``` r
launch_dashboard(...)
```

## Arguments

- ...:

  Additional arguments passed to
  [`shiny::runApp()`](https://rdrr.io/pkg/shiny/man/runApp.html).

## Value

A Shiny application object (invisibly).

## Examples

``` r
if (FALSE) { # \dontrun{
launch_dashboard()

# Launch on a specific port
launch_dashboard(port = 3838)
} # }
```
