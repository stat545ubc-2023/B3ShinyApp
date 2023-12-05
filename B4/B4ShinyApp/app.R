library(shiny)
library(dplyr)
library(ggplot2)
library(shinythemes)
library(DT)
forest_loss <- read.csv("Drivers of forest loss in Brazil Legal Amazon (Tyukavina et al. 2017).csv", stringsAsFactors = FALSE)
columnnames <- c("Entity", "Year", "Commercial Crops", "Tree Plantations Including Palm",	"Pasture", 
                 "Small-Scale Clearing",	"Roads",	"Other Infrastructure",	
                 "Flooding Due To Dams",	"Mining",	"Selective Logging",	"Fire",	
                 "Natural Disturbances",	"Total Forest Loss")
colnames(forest_loss) <- columnnames #rename column names to be more legible

ui <- fluidPage(
  titlePanel("Driving Factors in Brazil Legal Amazon Forest Loss", windowTitle = "Amazon Forest Loss"), #set title panel
  h4("A shiny app to display data characterizing the drivers of forest loss in the Brazil Legal Amazon from 2001-2018 sourced from Tyukavina et al. 2017"),
  h5("By Alex Wang"),
  sidebarLayout(
    sidebarPanel(
      sliderInput("yearInput", "Year", 2001, 2013, c(2001, 2013), sep = ""), #Feature 1: create slider to filter displayed data by year. 
      checkboxGroupInput("driverInput", "Drivers of Forest Loss", #Feature 2: create checkboxes to allow multiple selection to search multiple sources of forest loss.
                         choices = columnnames[3:length(columnnames)],
                         selected = columnnames[3:length(columnnames)]
                         ) #make checkbox choices to be column names from 3rd column and onward
    ),
    mainPanel(
      DT::DTOutput("ForestLossTable"), #Feature 3: create interactive table using DT package. 
      downloadButton("downloadForestLossTable", "Download Data"), #Additional Feature: create download button to download data of interest.
    )
  )
)
server <- function(input, output) {
  filtered_forest_loss <- reactive({ #make reactive variable
    forest_loss %>%
      filter(Year >= input$yearInput[1],
             Year <= input$yearInput[2]) %>% #filter data by sliderInput choices
      select("Entity", "Year", input$driverInput) #select data by checkboxGroupInput choices
  })
  output$ForestLossTable <- DT::renderDT({ #output interactive table with DT package
    filtered_forest_loss() 
  })
  output$downloadTable <- downloadHandler( #output download button
    filename = function() {
      "AmazonForestLoss.csv"  #suggested file name
    },
    content = function(file) {
      write.csv(filtered_forest_loss(), file) #write the dataset that will be downloaded
    }
  )
}
shinyApp(ui = ui, server = server)