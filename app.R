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


#code pour shinymanager
#ui <- fluidPage(
#  tags$h2("My secure application"),
#  verbatimTextOutput("auth_output")
#)

app_ui <- fluidPage(
  titlePanel(title = "Aviation NumbeRs"),
  navbarPage(
  title = "shinyauthr example",
  id = "tabs", # must give id here to add/remove tabs in server
  collapsible = TRUE,
  login_tab
)
)


#app_ui <-secure_app(
#app_ui <-fluidPage(
  # add logout button UI
#  div(class = "pull-right", shinyauthr::logoutUI(id = "logout")),
  # add login panel UI function
#  shinyauthr::loginUI(id = "login"),
  # setup table output to show user info after login

#    titlePanel(title = "Aviation NumbeRs"),
#
#    mainPanel(
#      navbarPage("En mode développement",
#        tab_accueil,
 #       tab_daily_delay,
#        tab_AC_load
#    ))

#########################################################################################################
#######################################    SERVER      ##################################################
#########################################################################################################

app_server <- function(input, output, session) {


  # hack to add the logout button to the navbar on app launch
  insertUI(
    selector = ".navbar .container-fluid .navbar-collapse",
    ui = tags$ul(
      class="nav navbar-nav navbar-right",
      tags$li(
        div(
          style = "padding: 10px; padding-top: 8px; padding-bottom: 0;",
          shinyauthr::logoutUI("logout")
        )
      )
    )
  )

  # call login module supplying data frame,
  # user and password cols and reactive trigger
  credentials <- shinyauthr::loginServer(
    id = "login",
    data = user_base,
    user_col = user,
    pwd_col = password,
    log_out = reactive(logout_init())
  )

  # call the logout module with reactive trigger to hide/show
  logout_init <- shinyauthr::logoutServer(
    id = "logout",
    active = reactive(credentials()$user_auth)
  )

  output$user_table <- renderTable({
    # use req to only render results when credentials()$user_auth is TRUE
    req(credentials()$user_auth)
    credentials()$info
  })


  #code pour shinymanager
  # check_credentials returns a function to authenticate users
#  res_auth <- secure_server(
#    check_credentials = check_credentials(credentials)
#  )

#  output$auth_output <- renderPrint({
#    reactiveValuesToList(res_auth)
#  })


mod_daily_delay_01_server("id")
#mod_AC_load_server("AC_load")



}

shinyApp(app_ui, app_server)
