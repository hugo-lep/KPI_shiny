
#fichier pour shinymanager
credentials <- data.frame(
  user = c("Julian", "Mathieu","dispatch","Hugo"), # mandatory
  password = c("Pascan2022", "Pascan2022","Pascan2022","admin"), # mandatory
  start = c("2019-04-15"), # optinal (all others)
  expire = c(NA,NA,NA,NA),
  admin = c(FALSE, FALSE,FALSE,TRUE),
  comment = "Simple and secure authentification mechanism
  for single ‘Shiny’ applications.",
  stringsAsFactors = FALSE
)
