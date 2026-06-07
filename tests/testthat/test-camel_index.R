test_that("camel_index works with data frames", {

  result <- camel_index(camel_2015, camel_2022)

  expect_s3_class(result, "camel_index")
  expect_equal(nrow(result$index_table), nrow(camel_2015))
  expect_named(result$index_table, c("bank", "I_mw", "PD"))
  expect_type(result$mw_lasp, "double")
  expect_type(result$mw_pash, "double")
  expect_type(result$I_mw, "double")
  expect_type(result$PD, "double")
  expect_length(result$weights_base, 5)
  expect_length(result$weights_current, 5)
})

test_that("camel_index works with matrices and bank_names", {

  base_mat <- as.matrix(camel_2015[, -1])
  curr_mat <- as.matrix(camel_2022[, -1])
  banks <- camel_2015$Bank

  result <- camel_index(base_mat, curr_mat, bank_names = banks)

  expect_s3_class(result, "camel_index")
  expect_equal(result$bank_names, as.character(banks))
})

test_that("camel_index validates input dimensions", {

  expect_error(
    camel_index(camel_2015, camel_2015[1:5, ]),
    "Dimension mismatch"
  )
})

test_that("camel_index requires bank_names for matrices", {

  base_mat <- as.matrix(camel_2015[, -1])
  curr_mat <- as.matrix(camel_2022[, -1])

  expect_error(
    camel_index(base_mat, curr_mat),
    "bank_names is required"
  )
})

test_that("camel_index handles single-column data frames", {
  expect_error(
    camel_index(data.frame(Bank = "A"), data.frame(Bank = "A")),
    "must have at least 2 columns"
  )
})

test_that("camel_index returns expected structure", {

  result <- camel_index(camel_2015, camel_2022)

  expected_names <- c(
    "index_table", "mw_lasp", "mw_pash", "I_mw", "PD",
    "weights_base", "weights_current", "eigenvalues_base",
    "eigenvalues_current", "n_factors_base", "n_factors_current",
    "fa_base", "fa_current", "relativity_data", "base_data",
    "current_data", "bank_names", "n_factors", "call"
  )

  expect_named(result, expected_names)
})

test_that("camel_index print method works", {

  result <- camel_index(camel_2015, camel_2022)

  expect_output(print(result), "CAMEL Index Results")
  expect_output(print(result), "Index Table")
  expect_output(print(result), "Communality Weights")
})

test_that("camel_index summary method works", {

  result <- camel_index(camel_2015, camel_2022)

  expect_output(summary(result), "CAMEL Index Summary")
  expect_output(summary(result), "Eigenvalues")
  expect_output(summary(result), "Index Distribution")
})
