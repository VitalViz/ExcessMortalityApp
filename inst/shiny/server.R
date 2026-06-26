

function(input, output, session) {


  observeEvent(input$instruction_link, {
    updateNavbarPage(session, inputId = "navbar_id", selected = "How To Use The App")
  })

  ## Read in data
  rvFile <- reactiveValues(clear = 0)
  getData <- reactive({
    morData <- input$readIn
    if (is.null(morData)) {
      return (NULL)
    }
    read.csv(input$readIn$datapath, stringsAsFactors = FALSE)
  })
  observeEvent(input$month_or_week, {
    rv$base <- NULL
    rv$excess <- NULL
  })

  # observeEvent(input$takeDataset1, {
  #   data(SampleInput1)
  # })

  output$downloadDataset1 <- downloadHandler(
    filename = function(){"SampleInput.csv"},
    content = function(file){
      data(SampleInput1)
      options(scipen = 100)
      write.csv(SampleInput1, file, row.names = FALSE)    
    } 
  )
  output$downloadDataset2 <- downloadHandler(
    filename = function(){"SampleInput_by_age.csv"},
    content = function(file){
      data(SampleInput2)
      out1 <- aggregate(deaths ~ year + month + age, data = SampleInput2, FUN = sum)
      out2 <- aggregate(population ~ year + month + age, data = SampleInput2, FUN = sum)
      out <- merge(out1, out2)
      out <- out[with(out, order(year, month, age)), ]
      options(scipen = 100)
      write.csv(out, file, row.names = FALSE)    
    } 
  )
  output$downloadDataset3 <- downloadHandler(
    filename = function(){"SampleInput_by_sex.csv"},
    content = function(file){
      data(SampleInput2)
      out1 <- aggregate(deaths ~ year + month + sex, data = SampleInput2, FUN = sum)
      out2 <- aggregate(population ~ year + month + sex, data = SampleInput2, FUN = sum)
      out <- merge(out1, out2)
      out <- out[with(out, order(year, month, sex)), ]
      options(scipen = 100)
      write.csv(out, file, row.names = FALSE)    
    } 
  )
  output$downloadDataset4 <- downloadHandler(
    filename = function(){"SampleInput_by_age_sex.csv"},
    content = function(file){
      data(SampleInput2)
      options(scipen = 100)
      write.csv(SampleInput2, file, row.names = FALSE)    
    } 
  )  
  output$downloadDataset5 <- downloadHandler(
    filename = function(){"SampleInput_weekly.csv"},
    content = function(file){
      data(SampleInput3)
      out1 <- aggregate(deaths ~ year + week, data = SampleInput3, FUN = sum)
      out2 <- aggregate(population ~ year + week, data = SampleInput3, FUN = sum)
      out <- merge(out1, out2)
      out <- out[with(out, order(year, week)), ]
      options(scipen = 100)
      write.csv(out, file, row.names = FALSE)    
    } 
  )  
  output$downloadDataset6 <- downloadHandler(
    filename = function(){"SampleInput_by_sex_weekly.csv"},
    content = function(file){
      data(SampleInput3)
      out1 <- aggregate(deaths ~ year + week + sex, data = SampleInput3, FUN = sum)
      out2 <- aggregate(population ~ year + week + sex, data = SampleInput3, FUN = sum)
      out <- merge(out1, out2)
      out <- out[with(out, order(year, week, sex)), ]
      options(scipen = 100)
      write.csv(out, file, row.names = FALSE) 
    } 
  )  
  output$downloadDataset7 <- downloadHandler(
    filename = function(){"SampleInput_by_age_weekly.csv"},
    content = function(file){
      data(SampleInput3)
      out1 <- aggregate(deaths ~ year + week + age, data = SampleInput3, FUN = sum)
      out2 <- aggregate(population ~ year + week + age, data = SampleInput3, FUN = sum)
      out <- merge(out1, out2)
      out <- out[with(out, order(year, week, age)), ]
      options(scipen = 100)
      write.csv(out, file, row.names = FALSE) 
    } 
  )  
  output$downloadDataset8 <- downloadHandler(
    filename = function(){"SampleInput_by_age_sex_weekly.csv"},
    content = function(file){
      data(SampleInput3)
      options(scipen = 100)
      write.csv(SampleInput3, file, row.names = FALSE)
    }
  )

  output$downloadDemo4 <- downloadHandler(
    filename = function(){"SampleInput4_partial_year.csv"},
    content = function(file){
      demo_path <- system.file("extdata", "SampleInput4.csv", package = "ExcessMortalityApp")
      if(demo_path == "") demo_path <- file.path(system.file(package = "ExcessMortalityApp"), "..", "..", "data-raw", "SampleInput4.csv")
      if(file.exists(demo_path)){
        file.copy(demo_path, file)
      }else{
        write.csv(data.frame(note = "Demo file not found"), file, row.names = FALSE)
      }
    }
  )
  output$downloadDemo5 <- downloadHandler(
    filename = function(){"SampleInput5_short_baseline.csv"},
    content = function(file){
      demo_path <- system.file("extdata", "SampleInput5.csv", package = "ExcessMortalityApp")
      if(demo_path == "") demo_path <- file.path(system.file(package = "ExcessMortalityApp"), "..", "..", "data-raw", "SampleInput5.csv")
      if(file.exists(demo_path)){
        file.copy(demo_path, file)
      }else{
        write.csv(data.frame(note = "Demo file not found"), file, row.names = FALSE)
      }
    }
  )
  output$downloadDemo6 <- downloadHandler(
    filename = function(){"SampleInput6_kmonth_demo.csv"},
    content = function(file){
      demo_path <- system.file("extdata", "SampleInput6.csv", package = "ExcessMortalityApp")
      if(demo_path == "") demo_path <- file.path(system.file(package = "ExcessMortalityApp"), "..", "..", "data-raw", "SampleInput6.csv")
      if(file.exists(demo_path)){
        file.copy(demo_path, file)
      }else{
        write.csv(data.frame(note = "Demo file not found"), file, row.names = FALSE)
      }
    }
  )

  output$downloadTemplate <- downloadHandler(
    filename = function(){
      paste0("template_", input$template_freq, "_", input$template_year_start, "-", input$template_year_end, ".csv")
    },
    content = function(file){
      yrs <- seq(input$template_year_start, input$template_year_end)
      if(input$template_freq == "monthly"){
        periods <- 1:12
        period_name <- "month"
      } else if(input$template_freq == "custom"){
        n_per <- as.numeric(input$template_n_periods)
        periods <- 1:n_per
        period_name <- "period"
      } else {
        periods <- 1:52
        period_name <- "week"
      }
      tmpl <- expand.grid(period = periods, year = yrs)
      colnames(tmpl)[1] <- period_name
      tmpl <- tmpl[order(tmpl$year, tmpl[[period_name]]), ]
      tmpl$deaths <- ""
      if("population" %in% input$template_groups) tmpl$population <- ""
      if("sex" %in% input$template_groups) tmpl$sex <- ""
      if("age" %in% input$template_groups) tmpl$age <- ""
      write.csv(tmpl, file, row.names = FALSE)
    }
  )

  output$fileUploaded <- reactive({
    updateSelectInput(session, "raw_data_population", 
                  choices = c("None (assumed no change)", colnames(getData())))
    if("population" %in% colnames(getData())){
      updateSelectInput(session, "raw_data_population", selected = "population")
    }
    updateSelectInput(session, "raw_data_sex", choices = c("None", colnames(getData())))
    if("sex" %in% colnames(getData())){
      updateSelectInput(session, "raw_data_sex", selected = "sex")
    }
    updateSelectInput(session, "raw_data_age", choices = c("None", colnames(getData())))
    if("age" %in% colnames(getData())){
      updateSelectInput(session, "raw_data_age", selected = "age")
    }
    dat <- getData()
    if(!is.null(dat)){
      cn <- tolower(colnames(dat))
      if("year" %in% cn){
        raw_years <- as.numeric(dat[, which(cn == "year")[1]])
        raw_years <- sort(unique(raw_years[!is.na(raw_years)]))
        if(length(raw_years) > 0){
          default_cutoff <- if(2020 %in% raw_years) 2020 else max(raw_years)
          updateNumericInput(session, "cutoff_year", value = default_cutoff, min = min(raw_years) + 1, max = max(raw_years))
          updateSliderInput(session, "exclude_range", min = min(raw_years), max = max(raw_years),
                            value = c(max(min(raw_years), 2020), min(max(raw_years), 2022)))
        }
      }
    }
    return(!is.null(getData()))
  })
  outputOptions(output, "fileUploaded", suspendWhenHidden = FALSE)

rv <- reactiveValues()
rv[["processed"]] <- FALSE

observeEvent(input$processMe, {
       morData <- getData()
       if(input$month_or_week == ""){
         output$message_file_upload <- renderText("Error: Please select a time scale.\n")
         return(NULL)
       }
       colnames(morData) <- tolower(colnames(morData))
       if("death" %in% colnames(morData) && "deaths" %in% colnames(morData) == FALSE){
          colnames(morData)[colnames(morData) == "death"] <- "deaths"
       }
       morData$deaths <- as.numeric(morData$deaths)
       if(sum(is.na(morData$deaths)) > 0){
         output$message_file_upload <- renderText("Error: 'deaths' column contains non-numerical values or NAs. Please check the input death counts.")
       }

       time_case <- input$month_or_week
       if(time_case == "Monthly"){
          T <- 12
          colnames(morData)[colnames(morData) == "month"] <- "timeCol"
       }else if(time_case == "Custom"){
          T <- as.numeric(input$n_periods)
          colnames(morData)[colnames(morData) == "period"] <- "timeCol"
          if(!"timeCol" %in% colnames(morData)){
            output$message_file_upload <- renderText("Error: 'period' column does not exist in the input data. Custom periods require a 'period' column.")
            rv$processed <- FALSE
            return(NULL)
          }
          if(T <= 2){
            showNotification(paste0("Note: Only ", T, " periods per year. Seasonal patterns will be very coarse."), type = "warning", duration = 8)
          }
       }else{
          T <- 53
          colnames(morData)[colnames(morData) == "week"] <- "timeCol"
       }

       if(!"timeCol" %in% colnames(morData)){
         if(time_case == "Monthly"){
              output$message_file_upload <- renderText("Error: 'month' column does not exist in the input data. Check your data file or the time scale is selected correctly.")
          }else if(time_case == "Custom"){
              output$message_file_upload <- renderText("Error: 'period' column does not exist in the input data. Check your data file or the time scale is selected correctly.")
          }else{
              output$message_file_upload <- renderText("Error: 'week' column does not exist in the input data. Check your data file or the time scale is selected correctly.")
          }
          rv$processed <- FALSE
          return(NULL)
       }else{
          output$message_file_upload <- NULL
       }
       if(sum(is.na(as.numeric(morData$timeCol))) > 0){
           output$message_file_upload <- renderText("Error: Time period in the input data includes non-numerical values. Check your data file.")
            return(NULL)
       }else{
          output$message_file_upload <- NULL
       }
       if(min(as.numeric(morData$timeCol), na.rm = TRUE) < 1){
           output$message_file_upload <- renderText("Error: Time period in the input data does not start from 1. Check your data file.")
            return(NULL)
       }else{
          output$message_file_upload <- NULL
       }
       if(max(as.numeric(morData$timeCol), na.rm = TRUE) > T){
        if(time_case == "Monthly"){
              output$message_file_upload <- renderText("Error: More than 12 months are found in the input data. Check your data file or the time scale is selected correctly.")
          }else if(time_case == "Weekly"){
              output$message_file_upload <- renderText("Error: More than 53 weeks are found in the input data. Check your data file or the time scale is selected correctly.")
          }else{
              output$message_file_upload <- renderText(paste0("Error: More than ", T, " periods found in the data. Check your data file or the number of periods per year."))
          }
          return(NULL)
       }else{
          output$message_file_upload <- NULL
       }
    
 
       if(input$raw_data_population == "None (assumed no change)"){
        morData$popCol <- NA
       }else{
        colnames(morData)[which(colnames(morData) == tolower(input$raw_data_population))] <- "popCol"
        morData$popCol <- as.numeric(morData$popCol)
        if(sum(is.na(morData$popCol)) > 0){
         output$message_file_upload <- renderText(paste0("Error: ", input$raw_data_population, " column contains non-numerical values or NAs. Please check the input population size."))
        }
       }
       if(input$raw_data_sex == "None"){
        morData$sexCol <- "All"
       }else{
        colnames(morData)[which(colnames(morData) == tolower(input$raw_data_sex))] <- "sexCol"
       }
       if(input$raw_data_age == "None"){
        morData$ageCol <-  "All"
       }else{
        colnames(morData)[which(colnames(morData) == tolower(input$raw_data_age))] <- "ageCol"
       }
       print(dim(morData))
       if(dim(morData)[1] == 0 ){
            output$message_file_upload <- renderText("Error: no data in the input. Check the formatting of the 'year' column to make sure it is numeric.")
             return(NULL)
       }
       rv[['cleanData']] <- morData
       years <- sort(unique(morData$year))

       ## ---------------------------------------------------------------------------------- ##
       ##  Create summary tables
       ## ---------------------------------------------------------------------------------- ##
       updateSelectInput(session, "baseline_show_sex", choices = c("All", unique(rv$cleanData$sexCol)))
       updateSelectInput(session, "baseline_show_age", choices = c("All", unique(rv$cleanData$ageCol)))
       updateSelectInput(session, "table_show_sex", choices = c("All", unique(rv$cleanData$sexCol)))
       updateSelectInput(session, "table_show_age", choices = c("All", unique(rv$cleanData$ageCol)))
       updateSelectInput(session, "compare_plot_by", 
            choices = c(
                ifelse(is.null(unique(rv$cleanData$sexCol)), NULL, "By Sex"),
                ifelse(is.null(unique(rv$cleanData$ageCol)), NULL, "By Age"),
                ifelse(is.null(unique(rv$cleanData$sexCol)) || is.null(unique(rv$cleanData$sexCol)), NULL, "By Sex and Age")
            )
        )

       ## ---------------------------------------------------------------------------------- ##
       ##  Compute baseline and analysis year splits
       ## ---------------------------------------------------------------------------------- ##

       cutoff_year <- input$cutoff_year
       exclude_years <- if(input$exclude_covid) seq(input$exclude_range[1], input$exclude_range[2]) else integer(0)

       years_obs <- sort(years[years < cutoff_year & !(years %in% exclude_years)])
       years_pand <- sort(years[years >= cutoff_year])
       rv[['years_obs']] <- years_obs
       rv[['years_pand']] <- years_pand
       rv[['cutoff_year']] <- cutoff_year

       n_baseline <- length(years_obs)
       if(n_baseline < 1){
         output$message_file_upload <- renderText("Error: No baseline years available. Increase the first year of the analysis period or adjust exclusion settings.")
         rv$processed <- FALSE
         return(NULL)
       }
       if(n_baseline < 2 && input$which_model == "Poisson Regression"){
         showNotification("Only 1 baseline year available. Switching to Simple Baseline model (Poisson Regression requires at least 2 baseline years).", type = "warning", duration = 10)
         updateSelectInput(session, "which_model", selected = "Simple Baseline")
       }
       warning_msg <- NULL
       if(n_baseline == 1) warning_msg <- paste0("Warning: Only 1 baseline year (", years_obs, "). No confidence intervals can be computed.")
       if(n_baseline == 2) warning_msg <- paste0("Warning: Only 2 baseline years (", paste(years_obs, collapse=", "), "). Confidence intervals may be unreliable.")
       if(n_baseline >= 3 && n_baseline < 5) warning_msg <- paste0("Note: ", n_baseline, " baseline years. 5 or more years are recommended for robust estimates.")
       output$baselineWarning <- renderText(warning_msg)

       ## ---------------------------------------------------------------------------------- ##
       ##  Compute baseline and excess
       ## ---------------------------------------------------------------------------------- ##

       # For Custom periods, use "Monthly" as the internal model time_case
       model_time_case <- if(time_case == "Custom") "Monthly" else time_case
       rv[['time_case']] <- time_case

       rv[['cleanTab']] <- summary_table(model_time_case, T, years, morData)
       if(input$which_model == "Simple Baseline" || (n_baseline < 2)){
         rv[['excess']] <- base_model(model_time_case, T, years, morData, "sexCol", "ageCol", "popCol", "timeCol", use.rate = FALSE, years_obs = years_obs, years_pand = years_pand)
       }else{

        show_modal_spinner(text = "Fitting the Excess Mortality Model") # show the spinner
        rv[['excess']] <- smooth_model(time_case = model_time_case, T = T, years = years, morData = morData, sexCol = "sexCol", ageCol = "ageCol", popCol = "popCol", timeCol = "timeCol", use.rate = TRUE, years_obs = years_obs, years_pand = years_pand)
        remove_modal_spinner() # hide the spinner
       }
       rv[["processed"]] <- TRUE


}
)


  plot_time_case <- reactive({
    if(input$month_or_week == "Custom") "Monthly" else input$month_or_week
  })

  output$baselinePlot <- renderPlotly({
     req(input$processMe)
     tryCatch({
       if(rv$processed) ggplotly(mortality_plot(rv$excess, input$baseline_show_sex, input$baseline_show_age, plot_time_case(), input$plot_show), tooltip = "text") %>% layout(legend = list(orientation = "v", x = 0.02, y = 0.98, xanchor = "left", yanchor = "top", bgcolor = "rgba(255,255,255,0.7)"))
      }, error = function(warn){
        return(NULL)
      })
  })

  output$download_baseplot = downloadHandler(
    filename = function() {
      paste0(input$plot_show, "_", input$month_or_week, "_Sex_", input$baseline_show_sex, "_Age_", input$baseline_show_age, '.pdf')
    },
    content = function(file) {
      ggsave(file, plot = mortality_plot(rv$excess, input$baseline_show_sex, input$baseline_show_age, plot_time_case(), input$plot_show), width = 8, height = 5)
    })

  output$comparePlot <- renderPlotly({
     req(input$processMe)
     tryCatch({
       if(rv$processed) {
        g <- compare_plot(rv$excess, input$compare_plot_by, plot_time_case(), input$compare_plot_show)
        ndim <- wrap_dims(length(unique(ggplot_build(g)$data[[1]]$PANEL)))
        if(ndim[1] == 1) ndim[1] <- 1.5
        if(ndim[2] == 1) ndim[2] <- 2
        gg <- ggplotly(g, tooltip = "text") 
        # hack to fix plotly legend change with multiple aes
        # for (i in 1:length(gg$x$data)){
        #     if (!is.null(gg$x$data[[i]]$name)){
        #       if(substr(gg$x$data[[i]]$name, 1, 1) == "(" && substr(gg$x$data[[i]]$name, nchar(gg$x$data[[i]]$name) - 2, nchar(gg$x$data[[i]]$name)) == ",1)"){
        #           gg$x$data[[i]]$name =  substr(gg$x$data[[i]]$name, 2, nchar(gg$x$data[[i]]$name)- 3)    
        #     }
        #     }
        # }
        ww <- ifelse(plot_time_case() == "Monthly", 300, 500)
        gg %>% layout(height = 360 * ndim[1], width = ww * ndim[2] + 200)
      }
      }, error = function(warn){
        return(NULL)
      })
  })

  output$download_compareplot = downloadHandler(
    filename = function() {
      paste0(input$compare_plot_show, "_", input$month_or_week, "_", input$compare_plot_by, '.pdf')
    },
    content = function(file) {
      ggsave(file, plot = compare_plot(rv$excess, input$compare_plot_by, plot_time_case(), input$compare_plot_show), width = 8)
    })

  output$baselineTab <- DT::renderDataTable({
     req(input$processMe)
     tryCatch({
       if(rv$processed){
         tab <- rv$excess$excess[[input$baseline_show_sex]][[input$baseline_show_age]]
          if(input$month_or_week == "Custom"){
              tab$Period <- tab$timeCol
              timeLabel = "Period"
          }else if(plot_time_case() == "Monthly"){
              tab$Month <- tab$timeCol
              timeLabel = "Month"
           }else{
              tab$Week <- tab$timeCol
              timeLabel = "Week"
           }

           tab <- tab[, c("year", timeLabel, "deaths", "excess", "lower", "upper")]
           colnames(tab)[1] <- "Year"
           colnames(tab)[3] <- "Actual Deaths"
           colnames(tab)[4] <- "Excess Deaths"
           colnames(tab)[5] <- "Lower limit of Excess (95% CI)"
           colnames(tab)[6] <- "Upper limit of Excess (95% CI)"
           if(input$month_or_week == "Custom"){
              tab <- tab[with(tab, order(Year, Period)), ]
           }else if(plot_time_case() == "Monthly"){
              tab <- tab[with(tab, order(Year, Month)), ]
           }else{
              tab <- tab[with(tab, order(Year, Week)), ]
           }
           rownames(tab) <- NULL
           tab <- tab %>% 
                DT::datatable(
                      extensions = 'Buttons', 
                      options = list(dom = 'Bfrtip',
                      buttons = c('copy', 'csv', 'excel', 'print'), 
                      pageLength = 20)) %>% 
                formatRound(columns = 3:6, digits = 0) 
           return(tab)
         }
       }, error = function(warn){
          return(NULL)
        })
  })


  output$tableSummary <- renderTable(rv$cleanTab[[input$table_show_type]][[input$table_show_sex]][[input$table_show_age]], digits = 0, align = "c", na = "")

  output$linePlotSummary <- renderPlotly({
    tab <- rv$cleanTab[[input$table_show_type]][[input$table_show_sex]][[input$table_show_age]]
    x <- colnames(tab)[1]
    tab[,1] <- factor(tab[,1], levels = tab[,1])
    years <- as.numeric(colnames(tab)[-1])
    cy <- if(!is.null(rv$cutoff_year)) rv$cutoff_year else 2020
    n_base <- max(1, length(years[years < cy]))
    n_analysis <- max(1, length(years[years >= cy]))
    colors <- c(grDevices::colorRampPalette(c('#6baed6', '#084594'))(n_base),
                grDevices::colorRampPalette(c('#fd8d3c', '#b10026'))(n_analysis))
    if(input$month_or_week == "Weekly"){
        ww <- " week"
        xlab <- "Week"
    }else if(input$month_or_week == "Custom"){
        ww <- " period"
        xlab <- "Period"
    }else{
        ww <- ""
        xlab <- "Month"
    }
    if(input$table_show_type == "Death Counts"){
      ylab <- "Death Count"
    }else{
      ylab <- "Death Rate"
    }
    fig <- plot_ly(tab, x = ~.data[[x]], name = x) %>%
                  layout(xaxis = list(title = xlab), 
                         yaxis = list(title = ylab), 
                         title = input$table_show_type)
    for(j in 2:ncol(tab)){
      tmp <- data.frame(x = tab[, 1], y = tab[, j])
      fig <- fig %>% add_trace(data = tmp, x = ~x, y = ~ y, name = colnames(tab)[j],
                               color =I(colors[which(years == colnames(tab)[j])]), 
                               type = "scatter", mode = 'lines+markers', 
                               hovertemplate = paste0(colnames(tab)[j], ww, ' %{x}: %{y}<extra></extra>')) 
    }
    fig
  })

}