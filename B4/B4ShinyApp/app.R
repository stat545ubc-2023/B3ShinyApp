library(shiny)
library(dplyr)
library(tidyr)
library(ggplot2)
library(shinythemes)
library(DT)
forest_loss <- read.csv("Drivers of forest loss in Brazil Legal Amazon (Tyukavina et al. 2017).csv", stringsAsFactors = FALSE) #load dataset
columnnames <- c("Entity", "Year", "Commercial Crops", "Tree Plantations Including Palm",	"Pasture", 
                 "Small-Scale Clearing",	"Roads",	"Other Infrastructure",	
                 "Flooding Due To Dams",	"Mining",	"Selective Logging",	"Fire",	
                 "Natural Disturbances",	"Total Forest Loss")
colnames(forest_loss) <- columnnames #rename column names to be more legible

ui <- fluidPage(
  theme = shinytheme("lumen"), #Feature 1: add lumen theme using shinytheme package. This is useful for improving the aesthetics of the app.
  titlePanel("Driving Factors of Brazil Legal Amazon Forest Loss", windowTitle = "Amazon Forest Loss"), #set title panel
  h4("Examining the drivers of forest loss in the Brazil Legal Amazon"),
  h5("By Alex Wang"),
  sidebarLayout(
    sidebarPanel(
      sliderInput("yearInput", "Choose Year Range:", 2001, 2013, c(2001, 2013), sep = ""), #create slider to filter displayed data by year. 
      checkboxGroupInput("driverInput", "Choose Driver(s) of Forest Loss:", #create checkboxes to allow multiple selection to search multiple sources of forest loss.
                         choices = columnnames[3:length(columnnames)], #make checkbox choices to be column names from Commercial Crops onwards
                         selected = columnnames[3:length(columnnames)-1] #make default selection to be everything selected except Total Forest Loss
                         ) 
    ),
    mainPanel(
      tabsetPanel( #Feature 2: create multiple tabs. This is useful to separate the various pages of the app.
        tabPanel("Welcome!",
                 p(),
                 img(src = "Map-of-the-Brazilian-legal-Amazon.png", height = 270, width = 320), # Feature 3: add image of Brazil Legal Amazon. This is useful to allow the user to see the geographic region the dataset is describing.
                 p(),
                 strong("Welcome to my shiny app! It was created to display data revealing the drivers of forest 
                 loss in the Brazil Legal Amazon (shown above) from 2001-2013 sourced from Tyukavina et al. 2017."), style = "font-size:16px",
                 p(),
                 "Use the tabs above to view a table (second tab) or histogram (third tab) detailing the area of forest loss associated with each particular driving factor.",
                 br(),
                 "You can use the download button below the table to download the data displayed.",
                 p(),
                 "Use the slider and checkboxes on the left to filter the data shown. This will also change what data you download!"),
        tabPanel("Amazon Forest Loss Table", 
                 p(),
                 DT::DTOutput("ForestLossTable"), #create interactive table using DT package 
                 downloadButton("downloadForestLossTable", "Download Data")), #create download button 
        tabPanel("Amazon Forest Loss Plot", 
                 p(),
                 plotOutput("ForestLossPlot")) #create plot
        )
      )
    )
  )
server <- function(input, output) {
  filtered_forest_loss <- reactive({forest_loss %>% #make reactive variable for data table output
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
  output$ForestLossPlot <- renderPlot({ #output histogram showing forest area lost vs year, with colors representing each driver of forest loss
    pivoted_forest_loss() %>%
      ggplot(aes(x = Year, y = Area_Lost)) +
      geom_col(aes(fill = Driver), width = 0.7) + 
      ylab("Area Lost") +
      ggtitle("Brazil Legal Amazon Forest Loss by Year") 
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