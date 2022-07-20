
##################################################################################
##########################   selection de la date ################################
##################################################################################

mod_daily_delay_01_ui <- function(id) {
  ns <- NS(id)
  tagList(
    dateInput(
      inputId = ns("date_selected"),
      label = "select a date",
      max = today(tzone = "UTC")- ddays(1),
      weekstart = 1,
      value = today() - ddays(1))
    )
}

##################################################################################
############################ checkbox retard serlement   #########################
#################################################################################

mod_daily_delay_02_ui <- function(id) {
  ns <- NS(id)
  tagList(
    checkboxInput(inputId = ns("if_delay"),
                  label = "afficher les vols en retard seulement",
                  value = TRUE)
  )
}

#################################################################################
############################ UI -> tous les retards ou 9 min.   #################
#################################################################################

mod_daily_delay_03_ui <- function(id){
  ns <- NS(id)
#  time_delay <- c("Tous","9 min. et +")
  tagList(
    conditionalPanel(condition = "input['id-if_delay']",      #   == 'true'",
                     selectInput(ns("min_retard"),
                                 label = "nombre de minutes de délai pour être considéré comme un retard",
                                 choices = c("Tous","9 min. et +"),
                                 selected = "9 min. et +"))
  )
}

#################################################################################
############################ UI -> stat des vols   #################
#################################################################################

mod_daily_delay_04_ui <- function(id){
  ns <- NS(id)
  tagList(
    textOutput(ns("nbr_flights")),
    textOutput(ns("nbr_delay")),
    textOutput(ns("ponctualite"))
  )
}

#################################################################################
############################ UI -> pour tableau des retard   #################
#################################################################################

mod_daily_delay_05_ui <- function(id){
  ns <- NS(id)
  tagList(
    textOutput(ns("min_retard")),
#    textOutput(ns("nbr_flights")),
    textOutput(ns("test")),
#    verbatimTextOutput(ns("test2")),
    rHandsontableOutput(ns("table"))
  )
}


####################################################################################################
##################### Section Serveur ##############################################################
####################################################################################################


mod_daily_delay_01_server <- function(id) {
  # Calling the moduleServer function
  moduleServer(
    # Setting the id
    id,
    # Defining the module core mechanism
    function(input, output, session) {

      login_info <- read_rds("static_files/login.rds")

      #URI pour l'appel API
      ressources <- reactive(
        str_c("flightStatuses?earliestDeparture=",
              as.character(input$date_selected),
              "&latestDeparture=",
              as.character(input$date_selected + ddays(1)))
      )

      flightstatuses <- reactive(
        content(GET(str_c('https://pascan-api.intelisys.ca/RESTv1/',
                          ressources()),
                    authenticate(login_info[1],
                                 login_info[2],
                                 type = "basic")
        )
        )
      )

      test26 <- reactive({

        data <- fct_flts_cleanup(flightstatuses()) #%>%

        data2 <- if ("delayMinutes" %in% names(data)){
          data
        } else {
          data %>%
            mutate(delayMinutes = NA,
                   delayCode.code = NA,
                   delayCode.name = NA_character_,
                   note = NA)
        }

        data3 <- data2 %>%
          mutate(note = if_else(included_delay == "" | is.na(included_delay),
                                str_c("<b>",note,"</b>"),
                                str_c("<b>",note,"</b>","<br><u>included delay</u><br>",included_delay)))
      })

      test28 <- reactive({

        time_delay2 <- reactive({
          case_when(input$min_retard == "Tous"~ 1,
                    input$min_retard == "9 min. et +"~ 9)
        })

        out <- test26() %>%
          filter(flightLegStatus.cancelled != TRUE) %>%
          group_by(tail) %>%
          group_split() %>%
          map_df(fct_code93)

        out <-  if(input$if_delay == FALSE){out
        }else{
          out %>% filter(
            difftime(depart_zulu_reel,depart_zulu_prevu,units = "mins") %>% as.numeric() >= time_delay2())
        }
      })

      output$table <- renderRHandsontable(
        test28() %>%
          #        select(-starts_with("flightLegStatus")) %>%
          mutate(Delay = as.numeric(difftime(depart_zulu_reel,depart_zulu_prevu,units = "mins")),
                 Delay = if_else(Delay > 0,
                                 str_c('<span style="color:red;"><center>',as.character(Delay)," mins</span>"),
                                 str_c('<span style="color:green;"><center>',as.character(Delay)," mins</span>")),

                 d_vol_prevu = difftime(arrivee_zulu_prevu,depart_zulu_prevu, units = "mins"),
                 d_vol_reel = difftime(arrivee_zulu_reel,depart_zulu_reel, units = "min"),


                 diff_blk_T = as.numeric(d_vol_reel-d_vol_prevu),
                 diff_blk_T = if_else(diff_blk_T > 0,
                                      str_c('<span style="color:red;">',"+",as.character(diff_blk_T),"</span>"),
                                      str_c('<span style="color:green;">',as.character(diff_blk_T),"</span>")),

                 delay_arr = if_else(as.numeric(delay_arr) > 0,
                                     str_c('<span style="color:red;text-decoration:overline;">',as.character(delay_arr)," mins</span></center>"),
                                     str_c('<span style="color:green;text-decoration:overline;">',"ON TIME","</span></center>")),
                 Delay = str_c(Delay,"<br>",diff_blk_T,"<br>",delay_arr),
                 #             delay_arr =difftime(arrivee_zulu_reel,arrivee_zulu_prevu, units = "mins"),


                 d_vol_prevu = as.character(d_vol_prevu),
                 d_vol_reel = as.character(d_vol_reel),
                 depart_zulu_prevu = str_sub(as.character(depart_zulu_prevu),-8,-4)) %>% #,
          #                depart_zulu_prevu = as.date(depart_zulu_prevu, )) %>%   #car rhandsometable ne semble pas accepter class difftime
          select(
            depart_zulu_prevu,
            flt_numb,
            Dep,
            Arr,
            tail,
            Delay,
            #          d_vol_prevu,
            #          d_vol_reel,
            diff_blk_T,
            any_of(c("delayCode.code",
                     "delayCode.name",
                     "note"))) %>% #,
          #         "included_delay"))) %>%
          #          Delay_code = delayCode.code,
          #          Delay_name = delayCode.name,
          #          note,
          #          included_delay) %>%
          rename("flight #" = flt_numb,
                 "Depart (Zulu)" = depart_zulu_prevu,
                 "Delay<br>Dep / blk time / Arr" = Delay,
                 "Diff blk time" = diff_blk_T,
                 "Delay Code" = delayCode.code,
                 "Delay Name" = delayCode.name) %>%
          #         "Diff blk time" = diff_blk_T) %>%

          rhandsontable(
            #            rename("flight #" = flt_numb),
            col_highlight = 5,
            #            rowHeaders = FALSE,
            readOnly = TRUE,
            allowedTags = "<br><p><small><h3><u><span><center>") %>%
          hot_cols(columnSorting = FALSE) %>%
          #        allowedTags = "<em><b><br><u><big>") %>%

          #  hot_col("depart_zulu_prevu", dateFormat = "hh:mm:ss"),
          hot_col("Depart (Zulu)",halign = "htCenter") %>%
          #      hot_col("Delay<br>Dep / blk time / Arr", halign = "htCenter") %>%
          hot_col(c("Delay<br>Dep / blk time / Arr","Delay Name","note"),renderer = "html") %>%
          hot_col(c("Delay<br>Dep / blk time / Arr","Delay Name","note"),renderer = htmlwidgets::JS("safeHtmlRenderer")) %>%
          #      hot_col("Delay<br>Dep / blk time / Arr", halign = "htCenter") %>%

          hot_col("Delay Code",halign = "htCenter") %>%
          #  hot_col("note", colWidths = 500) %>%
          hot_col("Diff blk time", halign = "htCenter") %>%
          hot_col("Diff blk time",
                  renderer = "
                  function (instance, td, row, col, prop, value, cellProperties) {
             Handsontable.renderers.NumericRenderer.apply(this, arguments);
             if (value > 0) {
             td.style.color = 'red';
             } else if (value < 0) {
             td.style.color = 'green';
             }
       }") %>%
          hot_col("Diff blk time", colWidths = 0.01) %>%

          hot_context_menu(allowRowEdit = FALSE, allowColEdit = FALSE)
      )

#      output$min_retard <- renderText(input$min_retard)
#      output$test <- renderText(as.Date(input$date_selected))
#      output$test2 <- renderPrint(str(test28()))

      output$nbr_flights <- renderText({
        str_c("Nombre de vols effectués: ",
              test26() %>% filter(flightLegStatus.cancelled != TRUE) %>% nrow())
      })

      output$nbr_delay <- renderText({
        str_c("Nombre de delai(s) au départ (> 9 mins): ",
              test26() %>% filter(flightLegStatus.cancelled != TRUE,
                                  delay_dep >= hms(minutes = 9)) %>%
                nrow())
      })

      output$ponctualite <- renderText({
        str_c("Ponctualité des départs:  ",
              round(1-
                      test26() %>% filter(flightLegStatus.cancelled != TRUE,
                                          delay_dep >= hms(minutes = 9)) %>%
                      nrow() /
                      test26() %>% filter(flightLegStatus.cancelled != TRUE) %>% nrow(),
                    2) *100,
              " %"
        )
      })

      })
    }


