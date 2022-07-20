fct_complete_flt <- function(data){
  data %>% map_df(fct_leg_details) #%>%
  #    arrange(flightLeg.departure.scheduledTime)
}
