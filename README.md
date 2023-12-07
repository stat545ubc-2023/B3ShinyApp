# B4 App :sparkles:
This is Alex Wang's Shiny App for Assignment B4 of STAT545. This app was made to be an interactive interface to examine the Drivers of Forest Loss in Brazil Legal Amazon (Tyukavina et al. 2017) dataset, available in the OWID Dataset Collection Github repository (https://github.com/owid/owid-datasets/tree/master/datasets). The map depicting the Brazil Legal Amazon is from Müller-Hansen et al. 2017 (https://doi.org/10.5194/npg-24-113-2017). 
\
\
The app can be accessed here: https://abwang28.shinyapps.io/B4ShinyApp/. :star2:
\
\
This app allows you to filter the data by year and by specific driver of forest loss. The first tab welcomes the user and gives a brief overview of the functionality of the app. There is also an image of the Brazil Legal Amazon to show the user the region of interest. In the second tab, the raw data is displayed as an interactive data table. In the third tab, the data is plotted as a histogram, highlighting the distribution of forest area lost by each forest loss driver per year. 
\
\
I have highlighted three specific features in the comments (Feature 1-3), although the app contains more than three features overall. Feature 1 uses the shinythemes package to add a theme, lumen, to the app, which improves the overall aesthetic appeal of the app. Feature 2 uses the tabsetPanel() function to create multiple tabs that separate the welcome page, the data table, and the plot, which improves ease of viewing and navigation. Feature 3 adds an image showing a map of the Brazil Legal Amazon (sourced from Müller-Hansen et al. 2017), which is useful to allow the user to see the region that the data set is about. :relaxed:
