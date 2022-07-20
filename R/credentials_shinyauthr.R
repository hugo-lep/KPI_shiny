# user database for logins avec shinyauthr
user_base <- tibble::tibble(
  user = c("Julian", "Mathieu","dispatch","Hugo"),
  password = purrr::map_chr(c("Pascan2022", "Pascan2022","Pascan2022","admin"), sodium::password_store),
  permissions = c("admin", "standard", "standard","admin"),
  name = c("Julian Roberts", "Mathieu Lafrenière","dispatch","Hugo")
)
