library(shiny)
library(httr)
library(rvest)
library(tidyverse)
library(RSelenium)
library(lubridate)


source("R/mod_AC_load.R")
#str_c("R/",list.files("R", pattern = "mod_AC_load_fct")) %>% map(source)



ui <- fluidPage(
  h1("test"),
  mod_AC_load_ui("load")
)

server <- function(input, output, session) {

  mod_AC_load_server("load")

}

shinyApp(ui, server)
