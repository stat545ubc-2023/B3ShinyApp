library(shiny)
library(dplyr)
library(stringr)
library(shinythemes)
whales <- read.csv("Whale catch (Rocha et al.; IWC).csv", stringsAsFactors =  FALSE)
whales <- whales %>% relocate("Bowhead.whale..Rocha.et.al...IWC.", .after = "Right.whale..Rocha.et.al...IWC.")
columnnames <- c("Entity", "Year", "Blue whale",	"Fin whale",	"Sperm whale",	"Humpback whale",	
                "Sei whale",	"Bryde's whale", "Minke whale", "Gray whale",	"Right whale", 
                "Bowhead whale",	"Unspecified/Other Species", "All whale species")
colnames(whales) <- columnnames

ui <- fluidPage(
  theme = shinytheme("cosmo"),
  titlePanel("Whale Catch Counts", windowTitle = "Whale Catch"),
  h3("A shiny app to display whale catch data sourced from Rocha et al. and the IWC"),
  sidebarLayout(
    sidebarPanel(
      sliderInput("yearInput", "Year", 1900, 2018, c(1900, 2018), sep = ""),
      checkboxGroupInput("speciesInput", "Species", 
                         choices = columnnames[3:length(columnnames)],
                         selected = columnnames[3:length(columnnames)]) #make choices as column names from 3 onward
      ),
    mainPanel(
      DT::DTOutput("catchtable"),
      downloadButton("downloadTable", "Download Data"),
      h4("Rocha, R. C., Clapham, P. J., & Ivashchenko, Y. V. (2014). Emptying the oceans: a summary of industrial whaling catches in the 20th century. Marine Fisheries Review, 76(4), 37-48."),
      h4("https://web.archive.org/web/20220613153315/https://iwc.int/public/downloads/8sXJb/Total_catches_since_1986.pdf")
    )
  )
)
server <- function(input, output) {
  filteredwhales <- reactive({
    whales %>%
    filter(Year >= input$yearInput[1],
           Year <= input$yearInput[2])%>%
    select("Entity", "Year", input$speciesInput)
  })
  output$catchtable <- DT::renderDT({
    filteredwhales()
    }
  )
  output$downloadTable <- downloadHandler(
    filename = function() {
      # Use the selected dataset as the suggested file name
      "WhaleCatchData.csv"
    },
    content = function(file) {
      # Write the dataset to the `file` that will be downloaded
      write.csv(filteredwhales(), file)
    }
  )
}

shinyApp(ui = ui, server = server)