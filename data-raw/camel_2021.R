library(readr)
# Data Preparation Script for CAMEL Ratio Data 2021
#
# This script reads in the dataset CamelRatioData_2021.csv
# which is sourced from the Ghanaian banking data.

# 2016 Year Data
camel_2021 <- read_csv("data-raw/CamelRatioData_2021.csv",
                       show_col_types = FALSE)

# Save as internal package data
usethis::use_data(camel_2021, overwrite = TRUE)

