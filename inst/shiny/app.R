# CamelRatiosIndex Shiny Dashboard
# A rich, interactive dashboard for computing and visualising
# multivariate-weighted CAMEL indices


# ---- Load required packages ----
library(shiny)
library(shinydashboard)
library(shinyWidgets)
library(shinycssloaders)
library(colourpicker)
library(DT)
library(plotly)
library(ggplot2)
library(dplyr)
library(tidyr)
library(tibble)
library(CamelRatiosIndex)

# ---- UI ----
ui <- dashboardPage(
  skin = "blue",

  dashboardHeader(
    title = tags$span(
      tags$img(src = "https://raw.githubusercontent.com/JC-Ayimah/CamelRatiosIndex/master/man/figures/logo.png",
               height = "40px", style = "margin-right: 10px; vertical-align: middle;"),
      "CamelRatiosIndex Dashboard"
    ),
    titleWidth = 350
  ),

  dashboardSidebar(
    width = 280,
    sidebarMenu(
      menuItem("Home", tabName = "home", icon = icon("home")),
      menuItem("Compute Index", tabName = "compute", icon = icon("calculator")),
      menuItem("Results", tabName = "results", icon = icon("chart-line")),
      menuItem("Visualisations", tabName = "visuals", icon = icon("chart-pie")),
      menuItem("Factor Analysis", tabName = "factor", icon = icon("project-diagram")),
      menuItem("Data Explorer", tabName = "data", icon = icon("table")),
      menuItem("About", tabName = "about", icon = icon("info-circle"))
    ),

    # Quick settings panel
    div(class = "sidebar-settings",
        style = "padding: 15px;",
        h4("Quick Settings", style = "color: white;"),
        numericInput("n_factors", "Number of Factors:", value = 3, min = 1, max = 5),
        awesomeCheckbox("scale_data", "Standardise Data", value = TRUE),
        awesomeCheckbox("auto_transform", "Auto-Transform Ratios", value = TRUE)
    )
  ),

  dashboardBody(
    tags$head(
      tags$style(HTML("
        .content-wrapper { background-color: #f4f6f9; }
        .box { border-top: 3px solid #1A5276; }
        .box.box-primary { border-top-color: #1A5276; }
        .box.box-success { border-top-color: #2ECC71; }
        .box.box-warning { border-top-color: #F39C12; }
        .box.box-danger { border-top-color: #E74C3C; }
        .info-box { min-height: 90px; }
        .info-box-icon { height: 90px; line-height: 90px; }
        .sidebar-settings { background: #1A5276; margin: 10px; border-radius: 5px; }
        .value-box { color: white; }
        .dataTables_wrapper .dataTables_paginate .paginate_button.current {
          background: #1A5276 !important; color: white !important;
        }
      "))
    ),

    tabItems(
      # ---- HOME TAB ----
      tabItem(tabName = "home",
        fluidRow(
          box(width = 12, status = "primary",
              h1("Welcome to the CamelRatiosIndex Dashboard", align = "center"),
              p("Compute multivariate-weighted CAMEL indices for bank performance assessment.",
                align = "center", style = "font-size: 16px; color: #666;")
          )
        ),
        fluidRow(
          infoBox("CAMEL Framework",
                  "5 Dimensions",
                  icon = icon("building-columns"),
                  color = "blue", width = 3),
          infoBox("Banks Analysed",
                  textOutput("n_banks_home"),
                  icon = icon("landmark"),
                  color = "green", width = 3),
          infoBox("Composite Index",
                  "Base = 100",
                  icon = icon("chart-line"),
                  color = "yellow", width = 3),
          infoBox("Methodology",
                  "Robust FA",
                  icon = icon("shield-halved"),
                  color = "red", width = 3)
        ),
        fluidRow(
          box(width = 6, title = "What is CAMEL?", status = "primary", solidHeader = TRUE,
              p("The CAMEL framework evaluates bank performance across five dimensions:"),
              tags$ul(
                tags$li(strong("C"), "apital Adequacy — ability to absorb losses"),
                tags$li(strong("A"), "sset Quality — quality of loan portfolio"),
                tags$li(strong("M"), "anagement Efficiency — operational efficiency"),
                tags$li(strong("E"), "arnings — profitability"),
                tags$li(strong("L"), "iquidity — ability to meet obligations")
              ),
              p("Higher values of Asset Quality, Management Efficiency, and Liquidity indicate
                 worse performance and are automatically inverted by the package.")
          ),
          box(width = 6, title = "How It Works", status = "info", solidHeader = TRUE,
              p("The dashboard implements the multivariate-weighted indexing method:"),
              tags$ol(
                tags$li("Upload base year and current year CAMEL ratio data"),
                tags$li("Robust factor analysis extracts communality-based weights"),
                tags$li("Laspeyres and Paasche indices are computed and averaged"),
                tags$li("Composite index (I_mw) and percentage difference (PD) are returned")
              ),
              p("Based on Ayimah et al. (2023).")
          )
        ),
        fluidRow(
          box(width = 12, title = "Sample Data Preview", status = "success", solidHeader = TRUE,
              DTOutput("sample_data_table")
          )
        )
      ),

      # ---- COMPUTE TAB ----
      tabItem(tabName = "compute",
        fluidRow(
          box(width = 6, title = "Upload Base Year Data", status = "primary", solidHeader = TRUE,
              fileInput("base_file", "Choose CSV File",
                        accept = c("text/csv", ".csv"),
                        buttonLabel = "Browse...",
                        placeholder = "No file selected"),
              awesomeCheckbox("use_builtin_base", "Use Built-in 2015 Data", value = TRUE),
              hr(),
              h5("Expected Format:"),
              tags$ul(
                tags$li("Column 1: Bank name (character)"),
                tags$li("Column 2: Capital Adequacy (Ca)"),
                tags$li("Column 3: Asset Quality (Aq) — will be inverted"),
                tags$li("Column 4: Management Efficiency (Me) — will be inverted"),
                tags$li("Column 5: Earnings (Eq)"),
                tags$li("Column 6: Liquidity (Lm) — will be inverted")
              )
          ),
          box(width = 6, title = "Upload Current Year Data", status = "warning", solidHeader = TRUE,
              fileInput("current_file", "Choose CSV File",
                        accept = c("text/csv", ".csv"),
                        buttonLabel = "Browse...",
                        placeholder = "No file selected"),
              awesomeCheckbox("use_builtin_current", "Use Built-in 2022 Data", value = TRUE),
              hr(),
              h5("Requirements:"),
              tags$ul(
                tags$li("Same number of banks as base year"),
                tags$li("Same column order as base year"),
                tags$li("Bank names in the same order")
              ),
              actionButton("compute_btn", "Compute Index",
                           icon = icon("calculator"),
                           class = "btn-success btn-lg",
                           style = "width: 100%; margin-top: 20px;")
          )
        ),
        fluidRow(
          box(width = 12, title = "Data Preview", status = "info", solidHeader = TRUE,
              tabBox(width = 12,
                tabPanel("Base Year", DTOutput("preview_base")),
                tabPanel("Current Year", DTOutput("preview_current"))
              )
          )
        )
      ),

      # ---- RESULTS TAB ----
      tabItem(tabName = "results",
        fluidRow(
          valueBoxOutput("best_bank_box", width = 4),
          valueBoxOutput("worst_bank_box", width = 4),
          valueBoxOutput("mean_index_box", width = 2),
          valueBoxOutput("mean_pd_box", width = 2)
        ),
        fluidRow(
          box(width = 8, title = "Index Table", status = "primary", solidHeader = TRUE,
              DTOutput("index_table") |> withSpinner(color = "#1A5276")
          ),
          box(width = 4, title = "Distribution Summary", status = "info", solidHeader = TRUE,
              plotlyOutput("index_dist_plot", height = "350px")
          )
        ),
        fluidRow(
          box(width = 6, title = "Top Performers", status = "success", solidHeader = TRUE,
              DTOutput("top_performers")
          ),
          box(width = 6, title = "Bottom Performers", status = "danger", solidHeader = TRUE,
              DTOutput("bottom_performers")
          )
        ),
        fluidRow(
          box(width = 12, title = "Download Results", status = "warning", solidHeader = TRUE,
              downloadButton("download_csv", "Download CSV", class = "btn-primary"),
              downloadButton("download_excel", "Download Excel", class = "btn-info"),
              downloadButton("download_rds", "Download RDS", class = "btn-success")
          )
        )
      ),

      # ---- VISUALISATIONS TAB ----
      tabItem(tabName = "visuals",
        fluidRow(
          box(width = 12, title = "CAMEL Index Visualisation Controls", status = "primary", solidHeader = TRUE,
              column(4, pickerInput("highlight_banks", "Highlight Banks:",
                                    choices = NULL, multiple = TRUE,
                                    options = list(`actions-box` = TRUE, `live-search` = TRUE))),
              column(4, colourInput("pos_color", "Positive Colour:", value = "#2ECC71")),
              column(4, colourInput("neg_color", "Negative Colour:", value = "#E74C3C"))
          )
        ),
        fluidRow(
          box(width = 12, title = "Percentage Difference Plot", status = "info", solidHeader = TRUE,
              plotlyOutput("main_plot", height = "500px") |>  withSpinner(color = "#1A5276")
          )
        ),
        fluidRow(
          box(width = 6, title = "Index Comparison (Bar Chart)", status = "success", solidHeader = TRUE,
              plotlyOutput("bar_plot", height = "400px")
          ),
          box(width = 6, title = "Performance Radar", status = "warning", solidHeader = TRUE,
              plotlyOutput("radar_plot", height = "400px")
          )
        ),
        fluidRow(
          box(width = 6, title = "Index Distribution (Histogram)", status = "primary", solidHeader = TRUE,
              plotlyOutput("hist_plot", height = "350px")
          ),
          box(width = 6, title = "Bank Ranking (Lollipop)", status = "info", solidHeader = TRUE,
              plotlyOutput("lollipop_plot", height = "350px")
          )
        )
      ),

      # ---- FACTOR ANALYSIS TAB ----
      tabItem(tabName = "factor",
        fluidRow(
          box(width = 6, title = "Eigenvalues (Base Year)", status = "primary", solidHeader = TRUE,
              plotlyOutput("eigen_plot_base", height = "350px")
          ),
          box(width = 6, title = "Eigenvalues (Current Year)", status = "warning", solidHeader = TRUE,
              plotlyOutput("eigen_plot_current", height = "350px")
          )
        ),
        fluidRow(
          box(width = 6, title = "Communality Weights", status = "success", solidHeader = TRUE,
              plotlyOutput("weights_plot", height = "400px")
          ),
          box(width = 6, title = "Weights Comparison Table", status = "info", solidHeader = TRUE,
              DTOutput("weights_table")
          )
        ),
        fluidRow(
          box(width = 12, title = "Factor Loadings (Base Year)", status = "primary", solidHeader = TRUE,
              DTOutput("loadings_table")
          )
        )
      ),

      # ---- DATA EXPLORER TAB ----
      tabItem(tabName = "data",
        fluidRow(
          box(width = 12, title = "Raw Data Explorer", status = "primary", solidHeader = TRUE,
              tabBox(width = 12,
                tabPanel("Base Year Data", DTOutput("raw_base")),
                tabPanel("Current Year Data", DTOutput("raw_current")),
                tabPanel("Relativity Data (Current/Base)", DTOutput("raw_relativity")),
                tabPanel("Laspeyres Index", DTOutput("raw_lasp")),
                tabPanel("Paasche Index", DTOutput("raw_pash"))
              )
          )
        )
      ),

      # ---- ABOUT TAB ----
      tabItem(tabName = "about",
        fluidRow(
          box(width = 12, title = "About CamelRatiosIndex", status = "primary", solidHeader = TRUE,
              h3("Package Information"),
              p(strong("Version:"), "1.1.0.900"),
              p(strong("Authors:"), "John Coker Ayimah, George Kyei Agyen, Raymond Achiyaale"),
              p(strong("License:"), "MIT"),
              p(strong("CRAN:"), a("https://CRAN.R-project.org/package=CamelRatiosIndex",
                                     href = "https://CRAN.R-project.org/package=CamelRatiosIndex")),
              p(strong("GitHub:"), a("https://github.com/JC-Ayimah/CamelRatiosIndex",
                                     href = "https://github.com/JC-Ayimah/CamelRatiosIndex")),
              p(strong("Documentation:"), a("https://JC-Ayimah.github.io/CamelRatiosIndex/",
                                           href = "https://JC-Ayimah.github.io/CamelRatiosIndex/")),
              hr(),
              h3("Methodology"),
              p("The multivariate weighting scheme employs robust factor analysis with OGK covariance
                 estimation to derive communality-based weights from the correlation matrix of CAMEL ratios.
                 The composite index is the arithmetic mean of Laspeyres-type and Paasche-type indices,
                 scaled to a base of 100."),
              p("Based on Ayimah, J. C., Mettle, F. O., Nortey, E. N., & Minkah, R. (2023).
                 A Robust Multivariate Weighting Technique for Computing a Measure for Inflation.
                 African Journal of Technical Education and Management, 3(1), 1-15."),
              hr(),
              h3("Citation"),
              pre("@Manual{,
  title = {CamelRatiosIndex: Multivariate-Weighted Indexing of CAMEL Ratios for Bank Performance Assessment},
  author = {John Coker Ayimah and George Kyei Agyen and Raymond Achiyaale},
  year = {2026},
  note = {R package version 1.0.0},
  url = {https://CRAN.R-project.org/package=CamelRatiosIndex}
}")
          )
        )
      )
    )
  )
)

# ---- SERVER ----
server <- function(input, output, session) {

  # Reactive values
  rv <- reactiveValues(
    base_data = NULL,
    current_data = NULL,
    result = NULL
  )

  # ---- Load data ----
  observe({
    if (input$use_builtin_base) {
      rv$base_data <- camel_2015
    } else if (!is.null(input$base_file)) {
      rv$base_data <- read.csv(input$base_file$datapath, stringsAsFactors = FALSE)
    }
  })

  observe({
    if (input$use_builtin_current) {
      rv$current_data <- camel_2022
    } else if (!is.null(input$current_file)) {
      rv$current_data <- read.csv(input$current_file$datapath, stringsAsFactors = FALSE)
    }
  })

  # ---- Compute index ----
  observeEvent(input$compute_btn, {
    req(rv$base_data, rv$current_data)

    withProgress(message = "Computing CAMEL Index...", value = 0, {
      incProgress(0.3, detail = "Running robust factor analysis")

      rv$result <- camel_index(
        base_data = rv$base_data,
        current_data = rv$current_data,
        n_factors = input$n_factors,
        scale_data = input$scale_data
      )

      incProgress(0.7, detail = "Done!")
    })

    # Update highlight bank choices
    updatePickerInput(session, "highlight_banks",
                      choices = rv$result$bank_names,
                      selected = rv$result$bank_names[1:3])

    showNotification("Index computed successfully!", type = "message")
  })

  # ---- HOME TAB outputs ----
  output$n_banks_home <- renderText({
    if (!is.null(rv$result)) {
      nrow(rv$result$index_table)
    } else {
      "21 (sample)"
    }
  })

  output$sample_data_table <- renderDT({
    data("camel_2015")
    datatable(camel_2015, options = list(pageLength = 5, scrollX = TRUE),
              class = "display compact") |>
      formatRound(columns = 2:6, digits = 4)
  })

  # ---- COMPUTE TAB outputs ----
  output$preview_base <- renderDT({
    req(rv$base_data)
    datatable(rv$base_data, options = list(pageLength = 10, scrollX = TRUE),
              class = "display compact") |>
      formatRound(columns = 2:ncol(rv$base_data), digits = 4)
  })

  output$preview_current <- renderDT({
    req(rv$current_data)
    datatable(rv$current_data, options = list(pageLength = 10, scrollX = TRUE),
              class = "display compact") |>
      formatRound(columns = 2:ncol(rv$current_data), digits = 4)
  })

  # ---- RESULTS TAB outputs ----
  output$best_bank_box <- renderValueBox({
    req(rv$result)
    best <- rv$result$index_table[which.max(rv$result$index_table$PD), ]
    valueBox(
      paste0(best$bank, " (+", best$PD, "%)"),
      "Best Performer",
      icon = icon("arrow-trend-up"),
      color = "green"
    )
  })

  output$worst_bank_box <- renderValueBox({
    req(rv$result)
    worst <- rv$result$index_table[which.min(rv$result$index_table$PD), ]
    valueBox(
      paste0(worst$bank, " (", worst$PD, "%)"),
      "Worst Performer",
      icon = icon("arrow-trend-down"),
      color = "red"
    )
  })

  output$mean_index_box <- renderValueBox({
    req(rv$result)
    valueBox(
      round(mean(rv$result$index_table$I_mw), 2),
      "Mean Index",
      icon = icon("scale-balanced"),
      color = "yellow"
    )
  })

  output$mean_pd_box <- renderValueBox({
    req(rv$result)
    valueBox(
      paste0(round(mean(rv$result$index_table$PD), 2), "%"),
      "Mean PD",
      icon = icon("percent"),
      color = "blue"
    )
  })

  output$index_table <- renderDT({
    req(rv$result)
    req(!is.null(rv$result$index_table))
    req(nrow(rv$result$index_table))

    datatable(rv$result$index_table,
              options = list(pageLength = 10, order = list(list(2,"desc"))),
              rownames = FALSE,
              class = "display compact") |>
      formatRound(columns = c("I_mw", "PD"), digits = 2) |>
      formatStyle("PD",
                  backgroundColor = styleInterval(0, c("#ffcccc", "#ccffcc")),
                  fontWeight = "bold")
  })

  output$index_dist_plot <- renderPlotly({
    req(rv$result)
    p <- ggplot(rv$result$index_table, aes(x = I_mw)) +
      geom_histogram(aes(fill = after_stat(x) > 100), bins = 8, colour = "white") +
      geom_vline(xintercept = 100, linetype = "dashed", colour = "red") +
      scale_fill_manual(values = c("TRUE" = "#2ECC71", "FALSE" = "#E74C3C"),
                        labels = c("Above Base", "Below Base")) +
      labs(x = "Composite Index (I_mw)", y = "Count", fill = "Performance") +
      theme_minimal()
    ggplotly(p)
  })

  output$top_performers <- renderDT({
    req(rv$result)
    top <- rv$result$index_table |>
      arrange(desc(PD)) |>
      head(5) |>
      mutate(Rank = row_number()) |>
      select(Rank, bank, I_mw, PD)

    datatable(top, rownames = FALSE, options = list(dom = 't')) |>
      formatRound(columns = c("I_mw", "PD"), digits = 2) |>
      formatStyle("PD", color = "green", fontWeight = "bold")
  })

  output$bottom_performers <- renderDT({
    req(rv$result)
    bottom <- rv$result$index_table |>
      arrange(PD) |>
      head(5) |>
      mutate(Rank = row_number()) |>
      select(Rank, bank, I_mw, PD)

    datatable(bottom, rownames = FALSE, options = list(dom = 't')) |>
      formatRound(columns = c("I_mw", "PD"), digits = 2) |>
      formatStyle("PD", color = "red", fontWeight = "bold")
  })

  # ---- VISUALISATIONS TAB outputs ----
  output$main_plot <- renderPlotly({
    req(rv$result)

    # check for highlighted banks
    has_highlight <- !is.null(input$highlight_banks) && length(input$highlight_banks) > 0

    plot_data <- rv$result$index_table |>
      mutate(bank_num = row_number())

    # only create colour_group if there are highlighted banks
    if (has_highlight){
      plot_data <- plot_data |>
        mutate(
          colour_group = ifelse(bank %in% input$highlight_banks, bank, "Other"),
          colour_group = factor(colour_group, levels = c(input$highlight_banks, "Other"))
        )
    } else {
      plot_data <- plot_data |>
        mutate(colour_group = "Other")
    }

    p <- suppressWarnings(ggplot(plot_data, aes(x = bank_num, y = PD, group = 1)) +
      geom_line(linewidth = 1, colour = "grey50") +
      geom_point(aes(colour = colour_group, text = paste0(bank, "<br>PD: ", PD, "%")),
                 size = 4) +
      geom_hline(yintercept = 0, linetype = "dashed", colour = "red") +
      scale_x_continuous(breaks = plot_data$bank_num, labels = plot_data$bank) +
      labs(x = "Bank", y = "Percentage Difference from Base Year (PD)",
           colour = "Bank", title = "CAMEL Index: Percentage Difference from Base Year") +
      theme_minimal() +
      theme(axis.text.x = element_text(angle = 45, hjust = 1, colour = 'black'))
    )

    if (has_highlight){
      n_colours <- length(input$highlight_banks)
      colours <- RColorBrewer::brewer.pal(min(n_colours, 8), "Set1")[1:n_colours]

      p <- p + scale_colour_manual(
        values = c(setNames(colours, input$highlight_banks), "Other" = 'grey70'),
        breaks = input$highlight_banks
      )
    } else {
      p <- p + scale_colour_manual(
        values = c("Other" = "gray70"),
        guide = 'none'
      )
    }

    ggplotly(p, tooltip = "text")
  })

  output$bar_plot <- renderPlotly({
    req(rv$result)
    p <- ggplot(rv$result$index_table, aes(x = reorder(bank, PD), y = PD,
                                            fill = PD > 0)) +
      geom_col() +
      coord_flip() +
      scale_fill_manual(values = c("TRUE" = input$pos_color, "FALSE" = input$neg_color),
                        labels = c("Decline", "Improvement")) +
      labs(x = "Bank", y = "PD (%)", fill = "Performance") +
      theme_minimal()
    ggplotly(p)
  })

  output$radar_plot <- renderPlotly({
    req(rv$result)
    # Create radar chart data
    radar_data <- data.frame(
      CAMEL = c("Capital", "Asset Quality", "Management", "Earnings", "Liquidity"),
      Weight = rv$result$weights_base
    )

    plot_ly(
      type = 'scatterpolar',
      mode = 'lines+markers',
      r = c(radar_data$Weight, radar_data$Weight[1]),
      theta = c(radar_data$CAMEL, radar_data$CAMEL[1]),
      fill = 'toself',
      fillcolor = 'rgba(26, 82, 118, 0.3)',
      line = list(color = '#1A5276', width = 2),
      marker = list(size = 8, color = '#1A5276')
    ) |>
      layout(
        polar = list(
          radialaxis = list(visible = TRUE, range = c(0, max(radar_data$Weight) * 1.2))
        ),
        title = "CAMEL Communality Weights (Base Year)"
      )
  })

  output$hist_plot <- renderPlotly({
    req(rv$result)
    p <- ggplot(rv$result$index_table, aes(x = PD)) +
      geom_histogram(aes(fill = after_stat(count)), bins = 8, colour = "white") +
      geom_vline(xintercept = 0, linetype = "dashed", colour = "red", linewidth = 1) +
      scale_fill_gradient(low = "#E74C3C", high = "#2ECC71") +
      labs(x = "Percentage Difference (PD)", y = "Frequency",
           title = "Distribution of Bank Performance") +
      theme_minimal()
    ggplotly(p)
  })

  output$lollipop_plot <- renderPlotly({
    req(rv$result)
    p <- ggplot(rv$result$index_table, aes(x = reorder(bank, I_mw), y = I_mw)) +
      geom_segment(aes(x = bank, xend = bank, y = 100, yend = I_mw),
                   colour = "grey50", linewidth = 1) +
      geom_point(aes(colour = I_mw > 100), size = 4) +
      geom_hline(yintercept = 100, linetype = "dashed", colour = "red") +
      scale_colour_manual(values = c("TRUE" = "#2ECC71", "FALSE" = "#E74C3C")) +
      coord_flip() +
      labs(x = "Bank", y = "Composite Index (I_mw)", color = "Above Base") +
      theme_minimal() +
      theme(legend.position = "none")
    ggplotly(p)
  })

  # ---- FACTOR ANALYSIS TAB outputs ----
  output$eigen_plot_base <- renderPlotly({
    req(rv$result)
    ev_df <- data.frame(
      Component = paste0("PC", seq_along(rv$result$eigenvalues_base)),
      Eigenvalue = rv$result$eigenvalues_base
    )
    p <- ggplot(ev_df, aes(x = Component, y = Eigenvalue)) +
      geom_col(fill = "#1A5276", alpha = 0.8) +
      geom_hline(yintercept = 1, linetype = "dashed", color = "red") +
      labs(title = "Base Year Eigenvalues", y = "Eigenvalue") +
      theme_minimal() +
      theme(axis.text = element_text(colour = 'black'))
    ggplotly(p)
  })

  output$eigen_plot_current <- renderPlotly({
    req(rv$result)
    ev_df <- data.frame(
      Component = paste0("PC", seq_along(rv$result$eigenvalues_current)),
      Eigenvalue = rv$result$eigenvalues_current
    )
    p <- ggplot(ev_df, aes(x = Component, y = Eigenvalue)) +
      geom_col(fill = "#F39C12", alpha = 0.8) +
      geom_hline(yintercept = 1, linetype = "dashed", color = "red") +
      labs(title = "Current Year Eigenvalues", y = "Eigenvalue") +
      theme_minimal() +
      theme(axis.text = element_text(colour = 'black'))
    ggplotly(p)
  })

  output$weights_plot <- renderPlotly({
    req(rv$result)
    weights_df <- data.frame(
      Ratio = c("Capital (Ca)", "Asset Quality (Aq)", "Management (Me)",
                "Earnings (Eq)", "Liquidity (Lm)"),
      Base = rv$result$weights_base,
      Current = rv$result$weights_current
    ) |>
      pivot_longer(cols = c(Base, Current), names_to = "Year", values_to = "Weight")

    p <- ggplot(weights_df, aes(x = Ratio, y = Weight, fill = Year)) +
      geom_col(position = "dodge", alpha = 0.8) +
      scale_fill_manual(values = c("Base" = "#1A5276", "Current" = "#F39C12")) +
      labs(x = "CAMEL Dimension", y = "Communality Weight", fill = "Year") +
      theme_minimal() +
      theme(axis.text.x = element_text(colour = 'black')) +
      coord_flip()
    ggplotly(p)
  })

  output$weights_table <- renderDT({
    req(rv$result)
    wt_df <- data.frame(
      Ratio = c("Capital (Ca)", "Asset Quality (Aq)", "Management (Me)",
                "Earnings (Eq)", "Liquidity (Lm)"),
      Base_Weight = round(rv$result$weights_base, 4),
      Current_Weight = round(rv$result$weights_current, 4),
      Difference = round(rv$result$weights_current - rv$result$weights_base, 4)
    )
    datatable(wt_df, rownames = FALSE, options = list(dom = 't')) |>
      formatRound(columns = 2:4, digits = 4)
  })

  output$loadings_table <- renderDT({
    req(rv$result)
    loadings <- as.data.frame(rv$result$fa_base@loadings)
    loadings$Ratio <- c("Capital (Ca)", "Asset Quality (Aq)", "Management (Me)",
                        "Earnings (Eq)", "Liquidity (Lm)")
    loadings <- loadings[, c("Ratio", setdiff(names(loadings), "Ratio"))]
    datatable(loadings, rownames = FALSE) |>
      formatRound(columns = 2:ncol(loadings), digits = 4)
  })

  # ---- DATA EXPLORER TAB outputs ----
  output$raw_base <- renderDT({
    req(rv$base_data)
    datatable(rv$base_data, options = list(pageLength = 10, scrollX = TRUE)) |>
      formatRound(columns = 2:ncol(rv$base_data), digits = 4)
  })

  output$raw_current <- renderDT({
    req(rv$current_data)
    datatable(rv$current_data, options = list(pageLength = 10, scrollX = TRUE)) |>
      formatRound(columns = 2:ncol(rv$current_data), digits = 4)
  })

  output$raw_relativity <- renderDT({
    req(rv$result)
    rel_df <- as.data.frame(rv$result$relativity_data)
    names(rel_df) <- c("Ca_ratio", "Aq_ratio", "Me_ratio", "Eq_ratio", "Lm_ratio")
    rel_df$Bank <- rv$result$bank_names
    rel_df <- rel_df[, c("Bank", names(rel_df)[1:5])]
    datatable(rel_df, options = list(pageLength = 10, scrollX = TRUE)) |>
      formatRound(columns = 2:6, digits = 4)
  })

  output$raw_lasp <- renderDT({
    req(rv$result)
    lasp_df <- data.frame(
      Bank = rv$result$bank_names,
      mw_lasp = round(rv$result$mw_lasp, 4)
    )
    datatable(lasp_df, rownames = FALSE, options = list(pageLength = 10))
  })

  output$raw_pash <- renderDT({
    req(rv$result)
    pash_df <- data.frame(
      Bank = rv$result$bank_names,
      mw_pash = round(rv$result$mw_pash, 4)
    )
    datatable(pash_df, rownames = FALSE, options = list(pageLength = 10))
  })

  # ---- DOWNLOADS ----
  output$download_csv <- downloadHandler(
    filename = function() { "camel_index_results.csv" },
    content = function(file) {
      req(rv$result)
      write.csv(rv$result$index_table, file, row.names = FALSE)
    }
  )

  output$download_rds <- downloadHandler(
    filename = function() { "camel_index_results.rds" },
    content = function(file) {
      req(rv$result)
      saveRDS(rv$result, file)
    }
  )

  output$download_excel <- downloadHandler(
    filename = function() { "camel_index_results.xlsx" },
    content = function(file) {
      req(rv$result)
      if (!requireNamespace("writexl", quietly = TRUE)) {
        install.packages("writexl")
      }
      writexl::write_xlsx(rv$result$index_table, file)
    }
  )
}

# ---- Run the app ----
shinyApp(ui = ui, server = server)
