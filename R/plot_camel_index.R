#' Plot CAMEL Index Percentage Differences
#'
#' Creates a ggplot2 line graph showing the percentage difference (PD) from the
#' base year for each bank, enabling visual comparison of bank performance
#' across the CAMEL framework.
#'
#' @param x An object of class \code{"camel_index"} returned by [camel_index()].
#' @param object An object of class \code{"camel_index"} (for the \code{autoplot} generic).
#' @param highlight_banks Optional character vector of bank names to highlight
#'   with distinct colours. All other banks are shown in grey.
#' @param add_reference_line Logical indicating whether to add a horizontal
#'   reference line at PD = 0 (the base year level). Default is `TRUE`.
#' @param point_size Numeric, size of points. Default is `3`.
#' @param line_size Numeric, size of line segments. Default is `0.8`.
#' @param colour_palette Character vector of colours for highlighted banks.
#'   Default uses a ColorBrewer qualitative palette.
#' @param title Optional plot title. If `NULL` (default), a descriptive title
#'   is generated.
#' @param subtitle Optional plot subtitle.
#' @param caption Optional plot caption. If `NULL` (default), a caption
#'   describing the base year is generated.
#' @param theme_fn A ggplot2 theme function. Default is [ggplot2::theme_minimal()].
#' @param ... Additional arguments passed to [ggplot2::geom_line()] and
#'   [ggplot2::geom_point()].
#'
#' @returns A ggplot object.
#'
#' @examples
#' # Basic plot
#' result <- camel_index(camel_2015, camel_2022)
#' plot_camel_index(result)
#'
#' # Highlight specific banks
#' plot_camel_index(result, highlight_banks = c("Absa", "Ecobank", "GCB"))
#'
#' # Custom styling
#' plot_camel_index(
#'   result,
#'   highlight_banks = c("Absa", "Ecobank"),
#'   title = "Bank Performance: 2015 vs 2022",
#'   subtitle = "Percentage difference from base year",
#'   color_palette = c("#E41A1C", "#377EB8"),
#'   theme_fn = ggplot2::theme_bw
#' )
#'
#' @export
plot_camel_index <- function(x,
                             highlight_banks = NULL,
                             add_reference_line = TRUE,
                             point_size = 3,
                             line_size = 0.8,
                             colour_palette = NULL,
                             title = NULL,
                             subtitle = NULL,
                             caption = NULL,
                             theme_fn = ggplot2::theme_minimal,
                             ...) {

  # Validate input
  if (!inherits(x, "camel_index")) {
    cli::cli_abort("`x` must be an object of class 'camel_index' returned by camel_index().")
  }

  # Prepare data
  plot_data <- tibble::tibble(
    bank = x$bank_names,
    pd = x$PD,
    bank_num = seq_along(x$bank_names)
  )

  # Determine colour scheme
  if (is.null(highlight_banks)) {
    # All banks in one colour
    plot_data$colour_group <- plot_data$bank
    n_colours <- length(unique(plot_data$bank))
    if (is.null(colour_palette)) {
      colour_palette <- .camel_palette(n_colours)
    }
  } else {
    # Highlight selected banks, grey out others
    highlight_banks <- as.character(highlight_banks)
    missing <- setdiff(highlight_banks, plot_data$bank)
    if (length(missing) > 0) {
      cli::cli_warn("The following banks were not found and will be ignored: {paste(missing, collapse = ', ')}")
      highlight_banks <- setdiff(highlight_banks, missing)
    }

    plot_data$colour_group <- dplyr::if_else(
      plot_data$bank %in% highlight_banks,
      plot_data$bank,
      "Other(s)"
    )

    n_colours <- length(highlight_banks) + 1  # +1 for "Other(s)"
    if (is.null(colour_palette)) {
      colour_palette <- c(.camel_palette(length(highlight_banks)), "grey70")
    } else {
      if (length(colour_palette) < n_colours) {
        cli::cli_warn("Not enough colours provided. Padding with defaults.")
        colour_palette <- c(colour_palette, .camel_palette(n_colours - length(colour_palette)))
      }
      colour_palette <- c(colour_palette[seq_len(length(highlight_banks))], "grey70")
    }
  }

  # Build plot
  p <- ggplot2::ggplot(plot_data, ggplot2::aes(x = bank_num, y = pd, group = 1)) +
    ggplot2::geom_line(
      linewidth = line_size,
      colour = if (is.null(highlight_banks)) "grey50" else "grey70",
      ...
    ) +
    ggplot2::geom_point(
      ggplot2::aes(colour = colour_group),
      size = point_size,
      ...
    ) +
    ggplot2::scale_colour_manual(
      name = "Bank",
      values = colour_palette,
      breaks = if (is.null(highlight_banks)) unique(plot_data$bank) else c(highlight_banks, "Other")
    ) +
    ggplot2::scale_x_continuous(
      breaks = plot_data$bank_num,
      labels = plot_data$bank
    ) +
    ggplot2::labs(
      x = "Bank",
      y = "Percentage Difference from Base Year (PD)",
      title = title %||% "CAMEL Index: Percentage Difference from Base Year",
      subtitle = subtitle,
      caption = caption %||% "Base year = 100. Positive values indicate improvement; negative values indicate decline."
    ) +
    theme_fn() +
    ggplot2::theme(
      axis.text.x = ggplot2::element_text(size = 10, colour = 'black'),
      legend.position = if (is.null(highlight_banks)) "none" else "right",
      panel.grid.major.x = ggplot2::element_blank(),
      panel.grid.minor = ggplot2::element_blank()
    )

  # Add reference line at PD = 0
  if (add_reference_line) {
    p <- p + ggplot2::geom_hline(
      yintercept = 0,
      linetype = "dashed",
      colour = "grey40",
      linewidth = 0.8
    )
  }

  p
}

#' @importFrom ggplot2 autoplot
#' @rdname plot_camel_index
#' @export
autoplot.camel_index <- function(object, ...) {
  plot_camel_index(object, ...)
}


# ---- Internal helper ----

#' Generate Colour Palette for CAMEL Plots
#'
#' Returns a qualitative colour palette suitable for bank comparison plots.
#'
#' @param n Number of colours needed.
#' @returns Character vector of hex colours.
#' @keywords internal
#' @noRd
.camel_palette <- function(n) {
  # ColorBrewer Set1 palette (colourblind-friendly, qualitative)
  base_palette <- c(
    "#E41A1C", "#377EB8", "#4DAF4A", "#984EA3",
    "#FF7F00", "#FFFF33", "#A65628", "#F781BF",
    "#999999", "#66C2A5", "#FC8D62", "#8DA0CB",
    "#E78AC3", "#A6D854", "#FFD92F", "#E5C494",
    "#B3B3B3", "#1B9E77", "#D95F02", "#7570B3",
    "#E7298A"
  )

  if (n <= length(base_palette)) {
    return(base_palette[seq_len(n)])
  }

  # If more colours needed, interpolate
  grDevices::colorRampPalette(base_palette)(n)
}


# Helper for NULL default values
`%||%` <- function(x, y) if (is.null(x)) y else x
