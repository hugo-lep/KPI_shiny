##################################################################################
##########################   selection de la date ################################
##################################################################################

mod_AC_load_ui <- function(id) {
  ns <- NS(id)
  tagList(
    actionButton(ns("update_sales"), "Update")
    dateInput(
      inputId = ns("date_selected"),
      label = "select a date",
      value = today() - ddays(1),
      weekstart = 1,
      daysofweekdisabled = c(0,2:6)
    ),
    actionButton("download_AC_load", "Download Data")
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

      last_update <- reactive(rea)
      sales <- eventReactive()


      Two_years_sales <- seq.Date(from = make_date(year = year(today() - dyears(2)), month = month(today()), day = 1),
               to = make_date(year = year(today()), month = month(today()), day = 1),
               by = "month") %>%
        as_tibble() %>%
        mutate(value = str_c("save_databases/detailed_sales_reports/",year(value),"_",month(value),".rds")) %>%
        slice_tail(n = 24) %>%
        as_vector() %>%
        map_df(read_rds)



walk(date_selection,correction)


#      login_info <- read_rds("static_files/login.rds")
#
#      #URI pour l'appel API
#      database <- eventReactive(input$download_AC_load,{
#        fct_AC_load(year(today()), month(today()),day(today()))
#      })
#    }
  )
}
