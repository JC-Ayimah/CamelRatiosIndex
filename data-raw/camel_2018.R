library(readr)
# Data Preparation Script for CAMEL Ratio Data 2018
#
# This script reads in the dataset CamelRatioData_2018.csv
# which is sourced from the Ghanaian banking data.

# 2016 Year Data
camel_2018 <- read_csv("data-raw/CamelRatioData_2018.csv",
                       show_col_types = FALSE)

# Save as internal package data
usethis::use_data(camel_2018, overwrite = TRUE)
