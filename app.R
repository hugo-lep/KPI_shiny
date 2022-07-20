# Main application
library(shinymanager)
library(here)
library(tidyverse)
library(lubridate)
library(shiny)
library(httr)
library(rhandsontable)
library(rvest)
library(RSelenium)
library(hms)




source("R/credentials.R")
source("R/mod_daily_delay_01.R")
#source("R/mod_AC_load.R")
#str_c("R/",list.files("R", pattern = "mod_AC_load_fct")) %>% map(source)
str_c("R/",list.files("R", pattern = "mod_dailydelay_fct")) %>% map(source)
str_c("R/",list.files("R", pattern = "tab_")) %>% map(source)


#########################################################################################################
#######################################    UI         ##################################################
#########################################################################################################

ui <- fluidPage(
  tags$h2("My secure application"),
  verbatimTextOutput("auth_output")
)


app_ui <-secure_app(

  fluidPage(
    titlePanel(title = "Aviation NumbeRs"),
#
#    mainPanel(
      navbarPage("En mode développement",
        tab_accueil,
        tab_daily_delay,
        tab_AC_load
    )))

#########################################################################################################
#######################################    SERVER      ##################################################
#########################################################################################################

app_server <- function(input, output, session) {

  # check_credentials returns a function to authenticate users
  res_auth <- secure_server(
    check_credentials = check_credentials(credentials)
  )

  output$auth_output <- renderPrint({
    reactiveValuesToList(res_auth)
  })


mod_daily_delay_01_server("id")
#mod_AC_load_server("AC_load")



}

shinyApp(app_ui, app_server)
