library(shiny)

ui <- fluidPage(
  h1("test")
)

server <- function(input, output, session) {

}

shinyApp(ui, server)
