test_that("plot_camel_index returns a ggplot object", {
  data("camel_2015")
  data("camel_2022")

  result <- camel_index(camel_2015, camel_2022)
  p <- plot_camel_index(result)

  expect_s3_class(p, "ggplot")
})

test_that("plot_camel_index highlights specific banks", {
  data("camel_2015")
  data("camel_2022")

  result <- camel_index(camel_2015, camel_2022)
  p <- plot_camel_index(result, highlight_banks = c("Absa", "Ecobank"))

  expect_s3_class(p, "ggplot")
})

test_that("plot_camel_index warns on missing highlight banks", {
  data("camel_2015")
  data("camel_2022")

  result <- camel_index(camel_2015, camel_2022)

  expect_warning(
    plot_camel_index(result, highlight_banks = c("Absa", "NonExistent")),
    "not found"
  )
})

test_that("plot_camel_index errors on non-camel_index input", {
  expect_error(
    plot_camel_index(list()),
    "must be an object of class 'camel_index'"
  )
})

test_that("plot_camel_index respects custom theme", {
  data("camel_2015")
  data("camel_2022")

  result <- camel_index(camel_2015, camel_2022)
  p <- plot_camel_index(result, theme_fn = ggplot2::theme_bw)

  expect_s3_class(p, "ggplot")
})

test_that("autoplot.camel_index works", {
  data("camel_2015")
  data("camel_2022")

  result <- camel_index(camel_2015, camel_2022)
  p <- autoplot(result)

  expect_s3_class(p, "ggplot")
})
