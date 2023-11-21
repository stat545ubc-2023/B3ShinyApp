library(shiny)
library(dplyr)
library(stringr)
library(shinythemes)
whales <- read.csv("Whale catch (Rocha et al.; IWC).csv", stringsAsFactors =  FALSE)
whales <- whales %>% relocate("Bowhead.whale..Rocha.et.al...IWC.", .after = "Right.whale..Rocha.et.al...IWC.") #reorganize data so that whale species columns are together
columnnames <- c("Entity", "Year", "Blue whale",	"Fin whale",	"Sperm whale",	"Humpback whale",	
                "Sei whale",	"Bryde's whale", "Minke whale", "Gray whale",	"Right whale", 
                "Bowhead whale",	"Unspecified/Other Species", "All whale species")
colnames(whales) <- columnnames #rename column names to be more concise

ui <- fluidPage(
  titlePanel("Whale Catch Counts", windowTitle = "Whale Catch"), #set title panel
  h4("A shiny app to display whale catch data up to 2018 sourced from Rocha et al. and the IWC"),
  h5("By Alex Wang"),
  sidebarLayout(
    sidebarPanel(
      sliderInput("yearInput", "Year", 1900, 2018, c(1900, 2018), sep = ""), #Feature 1: create slider to filter displayed data by year. This is useful to be able to narrow down years of interest for viewing, rather than viewing such a large range of years.
      checkboxGroupInput("speciesInput", "Species", #Feature 2: create checkboxes to allow multiple selection to search multiple whale species simultaneously. This is useful to selectively choose whale species of interest to display, rather than viewing all species.
                         choices = columnnames[3:length(columnnames)],
                         selected = columnnames[3:length(columnnames)]) #make checkbox choices to be column names from 3rd column and onward
      ),
    mainPanel(
      DT::DTOutput("catchtable"), #Feature 3: create interactive table using DT package. This is useful to allow for interaction with the data table, such as sorting of the table, searching the table, and choosing number of entries displayed per page. 
      downloadButton("downloadTable", "Download Data"), #Additional Feature: create download button to download data of interest. This is useful to allow users to download the data locally through the app.
      h5("Rocha, R. C., Clapham, P. J., & Ivashchenko, Y. V. (2014). Emptying the oceans: a summary of industrial whaling catches in the 20th century. Marine Fisheries Review, 76(4), 37-48."),
      h5("https://web.archive.org/web/20220613153315/https://iwc.int/public/downloads/8sXJb/Total_catches_since_1986.pdf"),
      h5("https://github.com/owid/owid-datasets/tree/master/datasets")
    )
  )
)
server <- function(input, output) {
  filteredwhales <- reactive({ #create reactive variable
    whales %>%
    filter(Year >= input$yearInput[1],
           Year <= input$yearInput[2]) %>% #filter data by sliderInput choices
    select("Entity", "Year", input$speciesInput) #select data by checkboxGroupInput choices
  })
  output$catchtable <- DT::renderDT({ #output interactive table with DT package
    filteredwhales() 
    }
  )
  output$downloadTable <- downloadHandler( #output download button
    filename = function() {
      "WhaleCatchData.csv"  #suggested file name
    },
    content = function(file) {
      write.csv(filteredwhales(), file) #write the dataset that will be downloaded
    }
  )
}

shinyApp(ui = ui, server = server)