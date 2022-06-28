#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
library(shiny)
library(rict)
library(purrr)
library(tidyr)
library(lubridate)
library(magrittr)
library(leaflet)
library(dplyr)
library(htmltools)

# Define UI for application --------------------------------------------------
ui <- tagList(
  navbarPage(
    "Bankside assessment",
    tabPanel(
      "Create Report",
      sidebarPanel(
        h4(em("This app is a work in progress!")),
        br(),
        br(),
        h4("Sample details:"),
        p(),
        selectInput("loc", "Location code",
          choices = select(utils::read.csv(system.file("extdat",
            "predictors.csv",
            package = "whpt"
          ),
          stringsAsFactors = FALSE, check.names = F
          ), `location_id`)
        ),
        dateInput("date", "Sampled date", format = "yyyy-mm-dd"),
        numericInput("aspt", "Observed ASPT", NA, min = 0),
        numericInput("ntaxa", "Observed NTAXA", NA, min = 0, step = 1),
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
  output$input_template <- downloadHandler(
    filename = function() {
      paste("input-template.csv", sep = "")
    },
    content = function(con) {
      template <- utils::read.csv(system.file("extdat",
        "input.csv",
        package = "whpt"
      ),
      stringsAsFactors = TRUE, check.names = F
      )

      write.csv(template[1, 1:4], con)
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
      ntaxa <- data.frame(
        "location_id" = input$loc,
        "date_taken" = input$date,
        "question" = "WHPT NTAXA Abund",
        "response" = input$ntaxa,
        check.names = F
      )

      aspt <- data.frame(
        "location_id" = input$loc,
        "date_taken" = input$date,
        "question" = "WHPT ASPT Abund",
        "response" = input$aspt,
        check.names = F
      )
      data <- dplyr::bind_rows(ntaxa, aspt)
    } else {
      data <- NULL
    }
    if (is.null(inFile) && is.null(data)) {
      return(NULL)
    }


    if (!is.null(inFile)) {
      # Create a Progress object
      progress <- shiny::Progress$new()
      # Make sure it closes when we exit this reactive, even if there's an error
      on.exit(progress$close())
      progress$set(message = "Calculating", value = 1)
      data <- read.csv(inFile$datapath,
                       check.names = F,
                       stringsAsFactors = FALSE)
      data$location_id <- as.character(data$location_id)
      data[data == ""] <- NA
      data[data == "#N/A"] <- NA
      data[data == "n/a"] <- NA
    }
    if (is.null(data)) {
      return(NULL)
    }
    input_data <- data

    # Predictions -----------------------------------------------------------
    predictors <- utils::read.csv(system.file("extdat",
      "predictors.csv",
      package = "whpt"
    ),
    stringsAsFactors = FALSE, check.names = F
    )

    data <- inner_join(data, predictors, by = c("location_id" = "location_id"))
    if (length(data[, 1]) == 0) {
      stop("Location ID doesn't match list of predefined locations -
           please contact Tim Foster")
    }
    data$sample_id <- paste(data$location_id, " ", data$date_taken)
    # Run predictions
    predictions <- whpt::whpt_predict(data)
    data <- inner_join(data, predictions, by = c("sample_id" = "sample_id"))
    predictions_table <- predictions
    output_files <- list(input_data)

    # Consistency -----------------------------------------------------------
    consistency <- whpt::consistency(data)
    consistency <- consistency %>% pivot_wider(names_from = assessment,
                                               values_from = value)

    data <- data %>%
      select(
        sample_id,
        date_taken,
        location_id,
        `Reported WHPT Class Year`,
        `Typical ASPT Class`,
        `Typical NTAXA Class`
      ) %>%
      unique()
    data <- inner_join(data, consistency, by = c("sample_id" = "sample_id"))
    consistency_table <- select(
      data,
      location_id,
      date_taken,
      `Reported WHPT Class Year`,
      `Typical ASPT Class`,
      `Typical NTAXA Class`,
      assessment,
      driver,
      action
    )
    water_bodies <- select(predictors,
                           location_id,
                           `water body previously classified`,
                           `water body used for typical class`)


    consistency_table <- inner_join(consistency_table,
                                    water_bodies,
                                    by = "location_id")

    consistency_table <- select(consistency_table,
                                location_id,
                                `water body previously classified`,
                                `water body used for typical class`,
                                everything())
    data <- inner_join(data, predictors, by = c("location_id" = "location_id"))

     predictors_reduced <- select(
      predictors,
      -`Typical ASPT Class`,
      -`Typical NTAXA Class`,
      -`Reported WHPT Class Year`,
      -`EX`,
      -`EY`,
      -`water body used for typical class`,
      -`water body sampled`,
      -`water body previously classified`
    )
     predictors_reduced <- predictors_reduced[
                               predictors_reduced$location_id %in%
                               input_data$location_id, ]
    output_files <- list(input_data, consistency_table, predictors_reduced)
    list_names <- c("input_data", "consistency_table", "predictors")

    # Map -------------------------------------------------------------------
    # Format NGR for Map
    data$NGR <- trimws(data$NGR)
    data$NGR <- gsub(pattern = " ", replacement = "", x = data$NGR)
    wgs <- suppressWarnings(rict::osg_parse(data$NGR, coord_system = "WGS84"))
    data$latitude <- wgs$lat
    data$longitude <- wgs$lon

    map <- leaflet(data) %>%
      addTiles() %>%
      addMarkers(~longitude, ~latitude, popup = ~ htmlEscape(location_id))

    output$map <- renderLeaflet(map)

    # Save report button -------------------------------------------------------
    create_report <- renderUI({
      downloadButton("create_report", "Generate report")
    })
    output$create_report <- downloadHandler(
      filename = paste0(format(data$date_taken,
                               "%Y-%m-%d"), "-",
                               data$locaiton_id,
                               ".docx"),
      content = function(file) {
        # Copy the report file to a temporary directory before processing it, in
        # case we don't have write permissions to the current working dir (which
        # can happen when deployed).
        tempReport <- file.path(tempdir(), "report.Rmd")
        tempImage <- file.path(tempdir(), "sepa-logo.png")
        tempTemplate <- file.path(tempdir(), "skeleton.docx")
        tempCss <- file.path(tempdir(), "styles.css")
        file.copy("report/report.Rmd", tempReport, overwrite = TRUE)
        file.copy("report/sepa-logo.png", tempImage, overwrite = TRUE)
        file.copy("report/skeleton.docx", tempTemplate, overwrite = TRUE)
        file.copy("report/styles.css", tempCss, overwrite = TRUE)
        params <- list(input_data, consistency_table, predictions, data)
        names(params) <- c("input_data",
                           "consistency_table",
                           "predictors",
                           "data")
        # Knit the document, passing in the `params` list, and eval it in a
        # child of the global environment (this isolates the code in the
        # document from the code in this app).
        rmarkdown::render(tempReport,
          output_file = file,
          params = params,
          envir = new.env(parent = globalenv())
        )
      }
    )

    return(list(
      # create_report,
      h3("Input Data"), DT::renderDataTable({
        input_data},
        rownames = FALSE,
        options = list(pageLength = 5, dom = 'tip')
      ),
      h3("Predictions"), DT::renderDataTable({
        predictions_table
      }, rownames = FALSE,
      options = list(pageLength = 5, dom = 'tip')),
      h3("Consistency Assessment"), DT::renderDataTable({
        consistency_table
      }, rownames = FALSE,
      options = list(pageLength = 5, dom = 'tip')),
      h3("Predictors"), DT::renderDataTable({
        predictors_reduced
      }, rownames = FALSE,
      options = list(pageLength = 5, dom = 'tip'))
    ))
  })
}

# Run the application ---------------------------------------------------------
shinyApp(ui = ui, server = server)
