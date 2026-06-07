library(readr)
# Data Preparation Script for CAMEL Ratio Data 2022
#
# This script reads in the dataset CamelRatioData_2022.csv
# which is sourced from the Ghanaian banking data.

# 2022 Year Data
camel_2022 <- read_csv("data-raw/CamelRatioData_2022.csv",
                       show_col_types = FALSE)

# Save as internal package data
usethis::use_data(camel_2022, overwrite = TRUE)
