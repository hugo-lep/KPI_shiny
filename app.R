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


#########################################################################################################
#######################################    UI         ##################################################
#########################################################################################################

ui <- fluidPage(
  tags$h2("My secure application"),
  verbatimTextOutput("auth_output")
)


app_ui <-secure_app(
#  theme = bslib::bs_theme(bootswatch = "darkly"),
  fluidPage(
    titlePanel(title = "Aviation NumbeRs"),
#
#    mainPanel(
      navbarPage("En mode développement",
        tabPanel("panel 1", "Accueil Dashboard"),
        tabPanel("Review daily delay",
                 fluidRow(column(4,mod_daily_delay_01_ui("id")),
                          column(4,mod_daily_delay_02_ui("id")),
                          column(4,mod_daily_delay_03_ui("id"))
                 ),
                 fluidRow(
                 mod_daily_delay_04_ui("id"),
                 h2("Tableau d'évaluation des retards (Délais au départ)"),
                 mod_daily_delay_05_ui("id")
                 )
        ),

        tabPanel("AC load",
                # mod_AC_load_ui("A/C_load")
        )
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


  # We are now calling the module server functions
  # on a given id that matches the one from the UI
#  mod_daily_delay_01_server(id = "choice_ui1")
#  mod_daily_delay_01_server(id = "choice_ui2")
}

shinyApp(app_ui, app_server)
