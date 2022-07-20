library(httr)
library(rvest)
library(tidyverse)
library(RSelenium)
library(lubridate)


##################################################################################
##########################   selection de la date ################################
##################################################################################

mod_AC_load_ui <- function(id) {
  ns <- NS(id)
  tagList(

    textOutput(ns("last_update")),
    actionButton(ns("download_AC_load"), "Click to update information"),

#    dateInput(
#      inputId = ns("date_selected"),
#      label = "select date to display",
#      value = today() - dweeks(1),
#      weekstart = 1,
#      daysofweekdisabled = c(0,2:6)
#    )

    tableOutput(ns("AC_load_table"))


  )
}

##################################################################################
##########################   serveur              ################################
##################################################################################

mod_AC_load_server <- function(id) {
  # Calling the moduleServer function
  moduleServer(
    # Setting the id
    id,
    # Defining the module core mechanism
    function(input, output, session) {

      last_update <- read_rds("save_databases/AC_load_database/last_update.rds")
      database <- read_rds("save_databases/AC_load_database/AC_load_database.rds")

#      last_update <- "2022-07-18"

#      login_info <- read_rds("static_files/login.rds")

      output$last_update <- renderText(paste0("Last update:", last_update))


      #URI pour l'appel API
#      database <- eventReactive(input$download_AC_load,{
#        mod_AC_load_fct_import()
#        mod_AC_load_fct_read_load()
#      })


     output$AC_load_table <- renderTable(
       database
     )


    }
  )
}
