#fct_AC_load(2022,07,18)
#library(reactable)

mod_AC_load_fct_read_load <- function(){

dossier_temporaire <- "temp_download/"
df <- read_csv(str_c(dossier_temporaire,list.files(dossier_temporaire)),
               skip = 3) %>%
  select(ROUTE,dtmRouteDate,Departure,Confirmed,Capacity
)

str_c(dossier_temporaire,"/",list.files(dossier_temporaire)) %>% map(file.remove)


df2 <- df %>%
  mutate(depart = word(Departure,2, sep = " "),
         arrivee = word(Departure,-1,sep = " "),
         jour = wday(dtmRouteDate, label = TRUE, abbr = TRUE,
                     week_start = getOption("lubridate.week.start",1),
                     locale = "en_US"),
         heure = word(Departure,1, sep = " "))

selected_date <- today()

df3 <- df2 %>% filter(dtmRouteDate >= selected_date,
                      dtmRouteDate < selected_date + ddays(7)) %>%
  select(ROUTE,depart,arrivee,"date" = dtmRouteDate, Confirmed,Capacity,jour,heure) %>%
  mutate(ratio = str_c(Confirmed,"/",Capacity),
         percent = round(Confirmed/Capacity,2)) %>%
  select(-Confirmed,-Capacity,-jour) %>%
  arrange(date)

df4 <- df3 %>%
  select(-percent) %>%
  pivot_wider(names_from = date, values_from = ratio)

df5 <- df3 %>%
  select(-ratio) %>%
  pivot_wider(names_from = date, values_from = percent)

vol_plus_75p <- df3 %>% filter(percent >= 0.75)

df_factor <- df3 %>%
  arrange(percent) %>%
  mutate(ratio = fct_inorder(ratio)) %>%
  arrange(date,heure) %>%
  select(-heure)

df_factor2 <- df_factor %>%
  select(-percent) %>%
  arrange(date) %>%
  pivot_wider(names_from = date, values_from = ratio) %>%
  arrange(ROUTE)

write_rds(df_factor2,"save_databases/AC_load_database/AC_load_database.rds")
df_factor2

}

#heatmap(df_factor2)


#ggplot(df_factor,mapping = aes(y = str_c(ROUTE,"/",depart,"/",arrivee), x = date, fill= percent)) +
#  geom_tile()









# install.packages("ggplot2")
#library(ggplot2)

#ggplot(df, aes(x = x, y = y, fill = value)) +
#  geom_tile()

