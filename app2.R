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

source("R/credentials_shinyauthr.R")
#source("R/mod_daily_delay_01.R")
source("R/mod_AC_load.R")
str_c("R/",list.files("R", pattern = "tab_")) %>% map(source)
#str_c("R/",list.files("R", pattern = "mod_dailydelay_fct")) %>% map(source)




# initial app UI with only login tab
ui <- fluidPage(
  titlePanel(title = "Aviation NumbeRs"),
  navbarPage(
  title = "",
  id = "tabs", # must give id here to add/remove tabs in server
  collapsible = TRUE,
  tab_login
))

server <- function(input, output, session) {

    mod_daily_delay_01_server("id")
  mod_AC_load_server("A/C_load")




















  ###########################################################################################
  ########## En bas de cette ligne c'est le code pour gérer les accès par utilisateur #######
  ###########################################################################################



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

  # call the shinyauthr login and logout server modules
  credentials <- shinyauthr::loginServer(
    id = "login",
    data = user_base,
    user_col = "user",
    pwd_col = "password",
    sodium_hashed = TRUE,
    reload_on_logout = TRUE,
    log_out = reactive(logout_init())
  )

  logout_init <- shinyauthr::logoutServer(
    id = "logout",
    active = reactive(credentials()$user_auth)
  )

  observeEvent(credentials()$user_auth, {
    # if user logs in successfully
    if (credentials()$user_auth) {
      # remove the login tab
      removeTab("tabs", "login")
      # add home tab + active
      appendTab("tabs", tab_accueil, select = TRUE)

      user_access <- read_rds("static_files/access.rds") %>%
        select(tab_id,credentials()$info$user) %>%
        filter(eval(parse(text = credentials()$info$user)) == TRUE,
               tab_id != "tab_accueil")

      # render user data output
#      output$user_data <- renderPrint({ dplyr::glimpse(credentials()$info) })
      # add data tab

#      user_access$tab_id %>% map(fct_access)
      user_access$tab_id %>% map(~insertTab("tabs",eval(parse(text = .))))


#      appendTab("tabs", data_tab)
      # render data tab title and table depending on permissions
#      user_permission <- credentials()$info$permissions
#      if (user_permission == "admin") {
#        output$data_title <- renderUI(tags$h2("Storms data. Permissions: admin"))
#        output$table <- DT::renderDT({ dplyr::storms[1:100, 1:11] })
#      } else if (user_permission == "standard") {
#        output$data_title <- renderUI(tags$h2("Starwars data. Permissions: standard"))
#        output$table <- DT::renderDT({ dplyr::starwars[, 1:10] })
#      }
    }
  })


}

shinyApp(ui, server)
