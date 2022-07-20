tab_daily_delay <- tabPanel("Review daily delay",
                            fluidRow(column(4,mod_daily_delay_01_ui("id")),
                                     column(4,mod_daily_delay_02_ui("id")),
                                     column(4,mod_daily_delay_03_ui("id"))
                            ),
                            fluidRow(
                              mod_daily_delay_04_ui("id"),
                              h2("Tableau d'évaluation des retards (Délais au départ)"),
                              mod_daily_delay_05_ui("id"),

                              h2("Tableau de vols annulés"),
                              mod_daily_delay_0_ui("id")

                            )
)
