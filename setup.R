# Setup script for CamelRatiosIndex package development

required_pkgs <- c("devtools", "usethis", "roxygen2", "testthat", "pkgdown",
                   "knitr", "rmarkdown", "lintr", "styler", "vdiffr")

for (pkg in required_pkgs) {
  if (!requireNamespace(pkg, quietly = TRUE)) {
    install.packages(pkg)
  }
}

library(devtools)

# Load the package for development
devtools::load_all()

# Check the package
devtools::check()

# Document the package
devtools::document()

# Run tests
devtools::test()

cat("
Setup complete!
")
cat("
Next steps:")
cat("
1. Update DESCRIPTION with your actual GitHub username")
cat("
2. Add your actual CAMEL data to data-raw/camel_data.R")
cat("
3. Run data-raw/camel_data.R to create built-in datasets")
cat("
4. Run devtools::check() frequently
")
