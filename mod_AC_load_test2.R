library(shiny)
library(httr)
library(rvest)
library(tidyverse)
library(RSelenium)
library(lubridate)



source("R/mod_AC_load.R")
str_c("R/",list.files("R", pattern = "mod_AC_load_fct")) %>% map(source)

ui <- fluidPage(
  h1("test2"),
  actionButton("click", "Click me!")
#  mod_AC_load_ui("load")
)

server <- function(input, output, session) {

}

shinyApp(ui, server)
