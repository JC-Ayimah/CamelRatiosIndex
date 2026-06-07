library(readr)
# Data Preparation Script for CAMEL Ratio Data 2016
#
# This script reads in the dataset CamelRatioData_2016.csv
# which is sourced from the Ghanaian banking data.

# 2016 Year Data
camel_2016 <- read_csv("data-raw/CamelRatioData_2016.csv",
                       show_col_types = FALSE)

# Save as internal package data
usethis::use_data(camel_2016, overwrite = TRUE)
