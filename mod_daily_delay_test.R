library(shiny)
library(tidyverse)
library(rhandsontable)
library(tidyverse)
library(hms)


source("R/mod_daily_delay_01.R")
str_c("R/",list.files("R", pattern = "mod_dailydelay_fct")) %>% map(source)





ui <- fluidPage(
  fluidRow(column(4,h3("mod_daily_delay_01_ui")),
           column(8,mod_daily_delay_01_ui("id"))),
  fluidRow(column(4,h3("mod_daily_delay_02_ui")),
           column(8,mod_daily_delay_02_ui("id"))),
  fluidRow(column(4,h3("mod_daily_delay_03_ui")),
           column(8,mod_daily_delay_03_ui("id"))),
  fluidRow(column(4,h3("mod_daily_delay_04_ui")),
           column(8,mod_daily_delay_04_ui("id"))),
  fluidRow(column(4,h3("mod_daily_delay_05_ui"))),
  fluidRow(8,mod_daily_delay_05_ui("id"))
)

server <- function(input, output, session) {

  mod_daily_delay_01_server("id")
}

shinyApp(ui, server)
