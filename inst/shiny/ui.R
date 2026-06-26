require("plotly")
require("DT")
require("ExcessMortalityApp")
require("markdown")
require("INLA")

ui <- fluidPage(
  use_busy_spinner(spin = "fading-circle"),

  tags$head(
    tags$style(HTML(".shiny-output-error-validation {
                    color: #ff0000;
                    font-weight: bold;}"))),
   tags$head(
    tags$link(rel = "stylesheet", type = "text/css", href = "style.css")
  ),
  titlePanel(
      title = div("Excess Mortality Calculator", 
      tags$a(img(src="vital_strategies.JPG", style="width:200px; position: relative; top: -1px;"), href="https://www.vitalstrategies.org/")),
      windowTitle =  "Excess Mortality Calculator"
    ),
  p("Developed by the openVA team", a(href="https://openva.net", "(https://openVA.net)."), "This work is supported by Vital Strategies as part of the Bloomberg Philanthropies Data for Health Initiative."),
  hr(),
  shinyjs::useShinyjs(),

  sidebarLayout(
    sidebarPanel(
      h4("Data Input"),
      fileInput("readIn",
                "Upload your own data here (CSV file)",
                multiple = FALSE,
                accept = c("text/csv", "text/comma-separated-values,text/plain", ".csv")),
      div(style = "margin-top: -20px"),
      actionLink("instruction_link", label = "Have questions? Read the instructions on how to use the App. You can also refer to the Example input data at the bottom of this section."),
      br(),
      br(),
      h4("Select Time Scale"),
      selectizeInput(
          inputId="month_or_week", label=NULL,
          choices=c("Monthly" = "Monthly",
                    "Weekly" = "Weekly",
                    "Custom periods" = "Custom"),
          options = list(
            placeholder = 'Please select an option below',
            onInitialize = I('function() { this.setValue(""); }')
          ),
          width="300px"
      ),
      conditionalPanel("input.month_or_week == 'Custom'",
        numericInput("n_periods", "Number of periods per year:",
                     value = 4, min = 2, max = 26, step = 1, width = "300px"),
        tags$small(tags$em("Input data must have a 'period' column (1 to N). Data should already be aggregated to the desired period level."),
                   style = "color: #666;")
      ),
      
      # selectInput(inputId="month_or_week", label=NULL,
      #             choices=c("Monthly" = "Monthly",
      #                       "Weekly" = "Weekly"),
      #             selected = NULL,
      #             width="200px"),
      h4("Select Model"),
      selectInput("which_model", NULL, choices=c("Poisson Regression", "Simple Baseline"), width="300px"),
      br(),
      h4("Baseline and Analysis Settings"),
      numericInput("cutoff_year", "First year of excess mortality period:", value = 2020, min = 2010, max = 2030, step = 1),
      checkboxInput("exclude_covid", "Exclude anomalous years from baseline", value = TRUE),
      conditionalPanel("input.exclude_covid",
        sliderInput("exclude_range", "Years to exclude:", min = 2010, max = 2030, value = c(2020, 2022), step = 1, sep = "")
      ),
      tags$div(id = "baseline_warning_area",
        textOutput("baselineWarning")
      ),
      tags$head(tags$style("#baselineWarning{color: #e67300; font-weight: bold; font-size: 13px;}")),
      br(),
      h4("Select Variables"),
      selectInput("raw_data_population", "Select Column Specifying Population Counts:", choices=c()),
      selectInput("raw_data_sex", "Select Column Specifying Sex:", choices=c()),
      selectInput("raw_data_age", "Select Column Specifying Age:", choices=c()),

  
      conditionalPanel("output.fileUploaded", 
        shinyWidgets::actionBttn("processMe", 
          label = "Analyze my data",
          size = "md",
          color = "primary",
          style = "jelly",
          icon = icon("sliders"),
          block = TRUE), 
        align = "center"),
      h4("Download demo input data:"),
      downloadLink(
          "downloadDataset1", "Monthly example dataset (2015-2021)"
      ),
      br(),
      downloadLink(
          "downloadDataset4", "Monthly example by sex and age (2015-2021)"
      ),
      br(),
      downloadLink(
          "downloadDataset8", "Weekly example by sex and age (2015-2021)"
      ),
      br(),
      downloadLink(
          "downloadDemo4", "Monthly example by sex and age, partial year (2015-2025)"
      ),
      br(),
      downloadLink(
          "downloadDemo5", "Monthly, short baseline (2018-2025)"
      ),
      br(),
      downloadLink(
          "downloadDemo6", "Quarterly by sex, custom period demo (2010-2024)"
      ),
      br(),
      br(),
      h4("Download blank template:"),
      fluidRow(
        column(6, numericInput("template_year_start", "Start year:", value = 2015, min = 1900, max = 2100, step = 1)),
        column(6, numericInput("template_year_end", "End year:", value = 2024, min = 1900, max = 2100, step = 1))
      ),
      selectInput("template_freq", "Frequency:", choices = c("Monthly" = "monthly", "Weekly" = "weekly", "Custom periods" = "custom"), selected = "monthly", width = "200px"),
      conditionalPanel("input.template_freq == 'custom'",
        numericInput("template_n_periods", "Periods per year:", value = 4, min = 2, max = 26, step = 1, width = "200px")
      ),
      checkboxGroupInput("template_groups", "Include columns:", choices = c("Sex" = "sex", "Age" = "age", "Population" = "population"), inline = TRUE),
      downloadBttn("downloadTemplate", "Download Template CSV", size = "sm", style = "unite", color = "default", block = TRUE),
      br(),
      br()
    ),
    ## Outputs
    mainPanel(
      textOutput("csvCheck"),
      navbarPage(title = NULL,
                 h4(textOutput("message_file_upload")),
                 tabPanel(title = "Excess Mortality",
                          fluidRow(
                            column(3, 
                                selectInput("plot_show", h4("Plot type"), choices=c("Death Counts", "Death Counts (Y-axis Starting From 0)", "Excess Death Counts"), width="400px"), 
                            ), 
                            column(3, 
                                selectInput("baseline_show_sex", h4("Sex"), choices=c(), width="400px"), 
                            ), 
                            column(3, 
                                selectInput("baseline_show_age", h4("Age"), choices=c(), width="400px")
                            )
                          ),
                          plotlyOutput("baselinePlot"),
                          conditionalPanel("input.processMe", 
                            downloadBttn("download_baseplot", "Download Plot", 
                                    size = "sm", 
                                    style = 'unite', 
                                    color = 'primary')
                          ),

                          br(),
                          br(),
                          DT::dataTableOutput("baselineTab")),
              tabPanel(title = "Comparison By Age And Sex",
                          fluidRow(
                            column(3, 
                                selectInput("compare_plot_show", h4("Plot type"), choices=c("Death Counts", "Excess Death Counts", "Excess Death Counts (Overlay)"), width="600px"), 
                            ), 
                            column(3, 
                                selectInput("compare_plot_by", h4("Comparison"), choices=c(), width="400px"), 
                            ),
                            column(5, 
                                conditionalPanel("input.processMe", 
                                  br(),
                                  br(),
                                  downloadBttn("download_compareplot", "Download Plot", 
                                    size = "sm", 
                                    style = 'unite', 
                                    color = 'primary')
                                ) 
                            )
                          ),
                          plotlyOutput("comparePlot")

                ),
              tabPanel(title = "Historical Data Explorer",
                          fluidRow(
                            column(3,
                              selectInput("table_show_type", h4("Historical Data"), choices=c("Death Counts", "Death Rate (Number of Deaths Per 100,000 Population)"), width="400px")
                            ), 
                            column(3,
                                selectInput("table_show_sex", h4("Sex"), choices=c(), width="400px"), 
                            ),
                            column(3,
                                selectInput("table_show_age", h4("Age"), choices=c(), width="400px"),
                            )
                          ),
                          plotlyOutput("linePlotSummary"),
                          tableOutput("tableSummary")), 
              tabPanel(title = "Methodology",
                withMathJax(),
                tags$div(HTML("<script type='text/x-mathjax-config'>
                MathJax.Hub.Config({
                'HTML-CSS': {
                      fonts: ['TeX'],
                      styles: {
                        scale: 110,
                        '.MathJax': { padding: '1em 0.1em', color: '#045a8d ! important' }
                      }
                    }
                });
                </script>
                ")),
                withMathJax(includeMarkdown("method.rmd"))
              ),
              tabPanel(title = "How To Use The App",
                withMathJax(includeMarkdown("instruction.rmd"))
              ), 
        id = "navbar_id"
      )
    )
  )
)
