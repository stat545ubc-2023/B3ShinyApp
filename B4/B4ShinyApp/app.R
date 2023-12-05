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
  theme = shinytheme("lumen"),
  titlePanel("Driving Factors in Brazil Legal Amazon Forest Loss", windowTitle = "Amazon Forest Loss"), #set title panel
  h4("A shiny app to display data characterizing the drivers of forest loss in the Brazil Legal Amazon from 2001-2018 sourced from Tyukavina et al. 2017"),
  h5("By Alex Wang"),
  sidebarLayout(
    sidebarPanel(
      sliderInput("yearInput", "Choose Year Range:", 2001, 2013, c(2001, 2013), sep = ""), #create slider to filter displayed data by year. 
      checkboxGroupInput("driverInput", "Choose Drivers of Forest Loss:", #create checkboxes to allow multiple selection to search multiple sources of forest loss.
                         choices = columnnames[3:length(columnnames)], #make checkbox choices to be column names from Commercial Crops onwards
                         selected = columnnames[3:length(columnnames)-1] #make default selection to be everything selected except Total Forest Loss
                         ) 
    ),
    mainPanel(
      tabsetPanel(
        tabPanel("Forest Loss Table", DT::DTOutput("ForestLossTable"), #create interactive table using DT package 
                 downloadButton("downloadForestLossTable", "Download Data")), #create download button to download data of interest
        tabPanel("Forest Loss Plot", plotOutput("ForestLossPlot"))
        )
    )
  )
)
server <- function(input, output) {
  filtered_forest_loss <- reactive({forest_loss %>% #make reactive variable for filtered data frame
      filter(Year >= input$yearInput[1],
             Year <= input$yearInput[2]) %>% #filter data by sliderInput choices
      select("Entity", "Year", input$driverInput) #select data by checkboxGroupInput choices
  }) 
  pivoted_forest_loss <- reactive({forest_loss %>% #make reactive variable for plot output
      select(!"Total Forest Loss") %>%
      pivot_longer(cols = !c(Entity, Year),
                   names_to = "Driver",
                   values_to = "Area_Lost") %>% #pivot longer for plotting
      filter(Year >= input$yearInput[1],
             Year <= input$yearInput[2]) %>% #filter data by sliderInput choices
      filter(Driver %in% input$driverInput) #filter data by checkboxGroupInput choices
  })
  output$ForestLossTable <- DT::renderDT({ #output interactive data table with DT package
    filtered_forest_loss() 
  })
  output$ForestLossPlot <- renderPlot({ #output plot
    pivoted_forest_loss() %>%
      ggplot(aes(x = Year, y = Area_Lost)) +
      geom_col(aes(fill = Driver), width = 0.7) +
      ylab("Area Lost") 
  })
  output$downloadForestLossTable <- downloadHandler( #output download button
    filename = function() {
      "AmazonForestLoss.csv"  #suggested file name
    },
    content = function(file) {
      write.csv(filtered_forest_loss(), file) #write the dataset that will be downloaded
    }
  )
}
shinyApp(ui = ui, server = server)