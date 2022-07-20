###########################################################################################
fct_code93 <- function(data){
  data %>%
    #    select(-delay_arr) %>%
    bind_cols(
      data %>% add_row(.before = 1) %>%
        slice_head(n = -1) %>%
        select(Arr2 = Arr,flt_numb2 = flt_numb,delay_arr_pr = delay_arr) %>%
        mutate(delay_arr_pr = as.character(delay_arr_pr)),

      data %>% select(next_flight_code = delayCode.code) %>%
        add_row() %>%
        slice(-1)
    ) %>%


    #################################
  mutate(initial_cause = if_else(next_flight_code == "93" & (delayCode.code != 93 | is.na(delayCode.code)),
                                 flt_numb,
                                 NA_character_)) %>%
    fill(initial_cause) %>%
    mutate(initial_cause = if_else(delayCode.code == "93",
                                   initial_cause,
                                   NA_character_)) %>%

    mutate(delayCode.name = if_else(delayCode.code == "93",
                                    str_c(delayCode.name,
                                          '<br><small>Previous flt: ',flt_numb2," arrived: ",
                                          '<span style="color:red;">',delay_arr_pr," mins late","</span>",
                                          '<br> Rotational caused by: flight ','<span style="color:red;">', initial_cause,"</span>","</small>"),
                                    delayCode.name))#%>%
  #    select(Dep,Arr,1:8) #%>%
  #    mutate(delay_dep = as.character(delay_dep))
}




