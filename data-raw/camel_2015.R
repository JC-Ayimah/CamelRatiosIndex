library(readr)
# Data Preparation Script for CAMEL Ratio Data 2015
#
# This script reads in the dataset CamelRatioData_2015.csv
# which is sourced from the Ghanaian banking data.

# 2015 Year Data
camel_2015 <- read_csv("data-raw/CamelRatioData_2015.csv",
                       show_col_types = FALSE)

# Save as internal package data
usethis::use_data(camel_2015, overwrite = TRUE)

