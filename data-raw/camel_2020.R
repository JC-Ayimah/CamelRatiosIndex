library(readr)
# Data Preparation Script for CAMEL Ratio Data 2020
#
# This script reads in the dataset CamelRatioData_2020.csv
# which is sourced from the Ghanaian banking data.

# 2016 Year Data
camel_2020 <- read_csv("data-raw/CamelRatioData_2020.csv",
                       show_col_types = FALSE)

# Save as internal package data
usethis::use_data(camel_2020, overwrite = TRUE)

