

fct_flts_cleanup <- function(data){

  cols_selection <- c(
    "flightLeg.departure.scheduledTime",
    "departure.estimatedTime",
    "flightLeg.arrival.scheduledTime",
    "arrival.estimatedTime",
    #  "flight.flightNumber",
    #  "tail.identifier",
    #  "departure.airport.code",
    #  "arrival.airport.code",
    "delayMinutes",
    "delayCode.code",
    "delayCode.name",
    "note",
    "included_delay",
    "departure.airport.href")

  out <- map(data,fct_legs) %>%
    map_df(fct_complete_flt)
  out <- out %>%
    select(depart_zulu_prevu =flightLeg.departure.scheduledTime,
           depart_zulu_reel = departure.estimatedTime,
           arrivee_zulu_prevu = flightLeg.arrival.scheduledTime,
           arrivee_zulu_reel = arrival.estimatedTime,

           flt_numb = flight.flightNumber,
           Dep = departure.airport.code,
           Arr = arrival.airport.code,
           legNumber,
           tail = tail.identifier,
           starts_with("flightLegStatus"),
           any_of(cols_selection)) %>%                                         #################
  #    filter(date(depart_zulu_prevu) == input$date_selected) %>%
  mutate(depart_zulu_prevu = ymd_hms(depart_zulu_prevu, tz = "UTC"),
         depart_zulu_reel = ymd_hms(depart_zulu_reel, tz = "UTC"),
         arrivee_zulu_reel = ymd_hms(arrivee_zulu_reel, tz = "UTC"),
         arrivee_zulu_prevu = ymd_hms(arrivee_zulu_prevu, tz = "UTC"),
         flt_numb = str_c(flt_numb," leg #",legNumber),
         delay_dep = difftime(depart_zulu_reel,depart_zulu_prevu, units = "mins"),
         delay_arr =difftime(arrivee_zulu_reel,arrivee_zulu_prevu, units = "mins")) %>%
    arrange(tail,depart_zulu_reel)
}

#test <- fct_flts_cleanup(flightstatuses)

#all.equal(test,test26)










