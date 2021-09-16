#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
library(shiny)
library(rict)
library(tidyverse)
library(leaflet)
library(dplyr)
library(htmltools)

# Define UI for application

ui <- tagList(
  #  shinythemes::themeSelector(),
  navbarPage(
    # theme = "cerulean",  # <--- To use a theme, uncomment this
    "Bankside assessment",
    tabPanel(
      "Report",
      sidebarPanel(
        h4("This app is a work in progress"),
        p(),
        fileInput("dataset", "Choose CSV File",
          accept = c(
            "text/csv",
            "text/comma-separated-values,text/plain",
            ".csv"
          )
        ),
        downloadButton(outputId = "input_template", label = "Download template"),
        p(),
        h4('Enter per site:'),
        p(),
        selectInput('loc', 'Location code', choices = select(utils::read.csv(system.file("extdat",
                                                                                                "predictors.csv",
                                                                                                package = "whpts"
        ),
        stringsAsFactors = FALSE, check.names = F
        ), `loc code`)
        ),
        dateInput('date', 'Sampled date', format = "yyyy-mm-dd"),
        numericInput('aspt', 'Observed ASPT', NA),
        numericInput('ntaxa', 'Observed NTAXA', NA),
        actionButton("goButton", "Go!", class = "btn-success")
      ),

      # Show tables
      mainPanel(
        leafletOutput("map"),
        p(),
        htmlOutput("tables")
      )
    )
  )
)

# Define server logic ------------------------------------------------------------------
server <- function(input, output) {

  output$input_template <-  downloadHandler(
    filename = function() {
      paste('input-template.csv', sep='')
    },
    content = function(con) {
      template <- utils::read.csv(system.file("extdat",
                                  "input.csv",
                                  package = "whpts"
      ),
      stringsAsFactors = TRUE, check.names = F
      )

      write.csv(template[1,1:4], con)
    }
  )

  output$tables <- renderUI({
    inFile <- input$dataset
    go <- input$goButton
    last <- input$goButton - 1
    if (go > last && go > 0) {
      progress <- shiny::Progress$new()
      # Make sure it closes when we exit this reactive, even if there's an error
      on.exit(progress$close())
      progress$set(message = "Calculating", value = 1)
      data <- data.frame(`loc code` = input$loc,
                         `Sampled date` = input$date,
                         `Reported NTAXA` = input$ntaxa,
                         `Reported ASPT` = input$aspt, check.names = F)

    } else {
      data <- NULL
    }
    if (is.null(inFile) && is.null(data)) {
      return(NULL)
    }


    if(!is.null(inFile)) {
      # Create a Progress object
      progress <- shiny::Progress$new()
      # Make sure it closes when we exit this reactive, even if there's an error
      on.exit(progress$close())
      progress$set(message = "Calculating", value = 1)
    data <- read.csv(inFile$datapath, check.names = F, stringsAsFactors = FALSE)
    data$`loc code` <- as.character(data$`loc code`)
  data[data == ""] <- NA
  data[data == "#N/A"] <- NA
  data[data == "n/a"] <- NA
    }
    if(is.null(data)) {
      return(NULL)
    }
    input_data <- data
    predictors <- utils::read.csv(system.file("extdat",
      "predictors.csv",
      package = "whpts"
    ),
    stringsAsFactors = FALSE, check.names = F
    )

    data <- inner_join(data, predictors, by = c("loc code" = "loc code"))
    if(length(data[,1]) == 0) {
      stop("Location code doesn't match list of predefined locations - please contact tim.foster@sepa.org.uk")
    }
    data$`Location code` <- data$`loc code`
    data$sample_id <- paste(data$`loc code`, " ", data$`Sampled date`)
    predictions <- whpts::whpt_predict(data)
    data <- inner_join(data, predictions, by = c("sample_id" = "sample_id"))
    data$`Reference ASPT` <- data$WHPT_ASPT
    data$`Reference NTAXA` <- data$WHPT_NTAXA
    predictions_table <- predictions

    output_files <- list(input_data)

    consistency_data <- whpts:::tidy_input(data)
    consistency <- whpts:::consistency(consistency_data)
    data <- inner_join(data, consistency, by = c("sample_id" = "sample_id"))
    consistency_table <- select(
      data,
      `Location code`,
      `Sampled date`,
      `Reported WHPT Class Year`,
      `Typical ASPT Class`,
      `Typical NTAXA Class`,
      `Reference ASPT`,
      `Reference NTAXA`,
      assessment,
      driver,
      action
    )

    predictors <- select(predictors, -`Typical ASPT Class`, -`Typical NTAXA Class`,  -`Reported WHPT Class Year`, -`EX`, -`EY`)
    predictors <- predictors[predictors$`loc code` %in% input_data$`loc code`, ]
    output_files <- list(input_data, consistency_table, predictors)
    list_names <- c("input_data", "consistency_table", "predictors")

    output$download_file <- downloadHandler(
      filename = function() {
        paste("rict-output", "zip", sep = ".")
      },
      content = function(fname) {
        fs <- c()
        tmpdir <- tempdir()
        setwd(tempdir())
        for (i in seq_along(output_files)) {
          path <- paste0(list_names[i], i, ".csv")
          fs <- c(fs, path)
          write.csv(output_files[[i]], file = path)
        }
        zip(zipfile = fname, files = fs)
      }
    )

    download_data <- renderUI({
      downloadButton("download_file", "Download Outputs")
    })

    # Format NGR
    data$NGR <- trimws(data$NGR)
    data$NGR <- gsub(pattern = " ", replacement = "", x = data$NGR)
    wgs <- suppressWarnings(rict::osg_parse(data$NGR, coord_system = "WGS84"))
    data$latitude <- wgs$lat
    data$longitude <- wgs$lon

    map <- leaflet(data) %>%
      addTiles() %>%
      addMarkers(~longitude, ~latitude, popup = ~ htmlEscape(`loc code`))

    output$map <- renderLeaflet(map)

    return(list(
      download_data,
      h3("Input Data"), DT::renderDataTable({
        input_data
      }),
      h3("Consistency Assessment"), DT::renderDataTable({
        consistency_table
      }),
      h3("Predictors"), DT::renderDataTable({
        predictors
      })
    ))
  })
}

# Run the application
shinyApp(ui = ui, server = server)
