# login tab ui to be rendered on launch
tab_login <- tabPanel(
  title = icon("lock"),
  value = "login",
  shinyauthr::loginUI("login")
)
