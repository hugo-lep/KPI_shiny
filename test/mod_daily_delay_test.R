library(shiny)


#source("R/mod_daily_delay_01.R")

setwd("E:/Hugo/R/r-project/Pascan/KPI_shiny")



ui <- fluidPage(
  mod_daily_delay_01_ui("id")
)
server <- function(input, output, session) {

  print(getwd())
#  mod_daily_delay_01_server("id")
}

shinyApp(ui, server)
