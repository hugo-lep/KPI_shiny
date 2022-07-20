library(httr)
library(rvest)
library(tidyverse)
library(RSelenium)
library(lubridate)
#source("R/mod_sales_fct_date&button.R")

#https://towardsdatascience.com/web-scraping-with-r-easier-than-python-c06024f6bf52
#https://riptutorial.com/r/example/23955/using-rvest-when-login-is-required
#https://adventuresindata.netlify.app/post/2018-01-17-viewing-rvest-sessions/
#https://jakobtures.github.io/web-scraping/  (book)
#https://thatdatatho.com/tutorial-web-scraping-rselenium/

#fct_sales_import()


fct_sales_import <- function(){

#  if(read_rds("save_databases/detailed_sales_reports/last_update.rds") == today()){
#    cat("database déjà été mise à jour aujourd'hui !")
#    stop()
  }

#  mois <- 07
#  annee <- 2022

#  remDr$close()
#  rD$server$stop()

  date_selection <- seq.Date(from = make_date(year = year(today() - dyears(2)), month = month(today()), day = 1),
                             to = make_date(year = year(today()), month = month(today()), day = 1),
                             by = "month") %>%
    as_tibble() %>%
    mutate(annee = year(value),
           mois = month(value)) %>%
    select(-value)

#ma_date <- make_date(year = annee,month = mois,day = 1)
#debut <-   format(ma_date, "%m/%d/%Y")
#fin <-   format(ma_date + dmonths(1) - ddays(1),"%m/%d/%Y")

#wd <- getwd()
#cprof <- getChromeProfile(wd, "Profile 1")
#remDr <- remoteDriver(browserName= "chrome", extraCapabilities = cprof)

remDr <- remoteDriver(
  remoteServerAddr = "localhost",
  port = 4445L,
#  port = free_port(),
  browserName = "chrome"
)


dossier_temporaire <- str_c(getwd() %>% str_replace_all("/", "\\\\\\"),"\\temp_download")
str_c(dossier_temporaire,"/",list.files(dossier_temporaire)) %>% map(file.remove)

eCaps <- list(
  chromeOptions =
    list(prefs = list('download.default_directory' = dossier_temporaire))
  #                      "download.prompt_for_download" = FALSE,))
)

rD <- RSelenium::rsDriver(
  browser = "chrome",
  chromever =
    # Get Chrome version
    system2(
      command = "wmic",
      args = 'datafile where name="C:\\\\Program Files (x86)\\\\Google\\\\Chrome\\\\Application\\\\chrome.exe" get Version /value',
      stdout = TRUE,
      stderr = TRUE
    ) %>%
    # Wrangling
    stringr::str_extract(pattern = "(?<=Version=)\\d+\\.\\d+\\.\\d+\\.") %>%
    magrittr::extract(!is.na(.)) %>%
    stringr::str_replace_all(pattern = "\\.", replacement = "\\\\.") %>%
    paste0("^",  .) %>%
    # Match versions
    stringr::str_subset(
      # List chromedriver versions
      string = binman::list_versions(appname = "chromedriver") %>% unlist()
    ),
  extraCapabilities = eCaps
)

remDr <- rD$client

#aller à la page d'accueil et se connecter
remDr$navigate("https://ameliawebreports.intelisys.ca/pascan/default.aspx")
webElem <- remDr$findElement(using = "xpath", '//*[(@id = "ucLogin_txtBoxUsername")]')
webElem$sendKeysToElement(list("HUGO"))
webElem <- remDr$findElement(using = "xpath", '//*[(@id = "ucLogin_txtBoxPassword")]')
webElem$sendKeysToElement(list("LEPAGE"))
webElem <- remDr$findElement(using = "xpath", '//*[(@id = "ucLogin_cmd_login")]')
webElem$sendKeysToElement(list("LEPAGE", key = "enter"))
Sys.sleep(3)

# une fois connecter
webElem <- remDr$findElement(using = "xpath", '//*[(@id = "ucReportBuilder_reports")]')
webElem$sendKeysToElement(list("Detailed Sales"))
Sys.sleep(3)


webElem <- remDr$findElement(using = "xpath", '//*[(@id = "ucReportBuilder_format")]')
webElem$sendKeysToElement(list("CSV"))
Sys.sleep(3)
webElem <- remDr$findElement(using = "xpath", '//*[@id="ucReportBuilder_tblParamas"]/tbody/tr/td[1]/table/tbody/tr[2]/td[1]/select')
webElem$sendKeysToElement(list("<ALL>"))
print("check point no 1")
Sys.sleep(5)
print("check point no 2")
webElem <- remDr$findElement(using = "xpath", '//*[@id="ucReportBuilder_tblParamas"]/tbody/tr/td[1]/table/tbody/tr[2]/td[2]/input[1]')
webElem$sendKeysToElement(list(" ", key = "enter"))
print("check point no 3")
############################################################ R selenium quand j'utilise une fonction ########### début de la fonction ici
Sys.sleep(3)

date_selection2 <- date_selection %>% slice_tail(n =2) #anti_join(
#  list.files("save_databases/detailed_sales_reports") %>%
#    as_tibble() %>%
#    mutate(annee = word(value,1, sep = c("_")),
#           mois = word(value %>% str_remove(".rds"),2, sep = "_")) %>%
#    select(-value) %>%
#    mutate(across(everything(),as.double))) %>%
#mod_sales_fct_date_button(date_selection2,dossier_temporaire)

print("loop check point 1")
ma_date <- make_date(year = date_selection2[1,1],month = date_selection2[1,2],day = 1)
debut <-   format(ma_date, "%m/%d/%Y")
fin <-   format(ma_date + dmonths(1) - ddays(1),"%m/%d/%Y")
print("loop check point 2")
webElem <- remDr$findElement(using = "xpath", '//*[(@id = "ucReportBuilder_dtm_from_date")]')
webElem$clearElement()
Sys.sleep(1)
webElem$sendKeysToElement(list(debut))
print("loop check point 3")
Sys.sleep(1)
webElem <- remDr$findElement(using = "xpath", '//*[(@id = "ucReportBuilder_dtm_to_date")]')
webElem$clearElement()
Sys.sleep(1)
webElem$sendKeysToElement(list(fin))
Sys.sleep(2)

webElem <- remDr$findElement(using = "xpath", '//*[@id="ucReportBuilder_cmdCreateReport"]')
webElem$sendKeysToElement(list(" ", key = "enter"))


Sys.sleep(5)


data <- read_csv(str_c(dossier_temporaire,"/",list.files(dossier_temporaire)),
                 show_col_types = FALSE) %>%
  select(-starts_with("Textbox")) %>%
  mutate(across(.cols = c(1:2),mdy_hms),
         across(.cols = c(3:5,15),as_factor))

data %>% write_rds(str_c("save_databases/detailed_sales_reports/",date_selection2[1,1],"_",date_selection2[1,2],".rds"))
Sys.sleep(1)

str_c(dossier_temporaire,"/",list.files(dossier_temporaire)) %>% map(file.remove)

################# on recommence parce qu'un loop (map) fait planter Rselenium ###############

print("loop check point 1")
ma_date <- make_date(year = date_selection2[2,1],month = date_selection2[2,2],day = 1)
debut <-   format(ma_date, "%m/%d/%Y")
fin <-   format(ma_date + dmonths(1) - ddays(1),"%m/%d/%Y")
print("loop check point 2")
webElem <- remDr$findElement(using = "xpath", '//*[(@id = "ucReportBuilder_dtm_from_date")]')
webElem$clearElement()
Sys.sleep(1)
webElem$sendKeysToElement(list(debut))
print("loop check point 3")
Sys.sleep(1)
webElem <- remDr$findElement(using = "xpath", '//*[(@id = "ucReportBuilder_dtm_to_date")]')
webElem$clearElement()
Sys.sleep(1)
webElem$sendKeysToElement(list(fin))
Sys.sleep(2)

webElem <- remDr$findElement(using = "xpath", '//*[@id="ucReportBuilder_cmdCreateReport"]')
webElem$sendKeysToElement(list(" ", key = "enter"))


Sys.sleep(5)


data <- read_csv(str_c(dossier_temporaire,"/",list.files(dossier_temporaire)),
                 show_col_types = FALSE) %>%
  select(-starts_with("Textbox")) %>%
  mutate(across(.cols = c(1:2),mdy_hms),
         across(.cols = c(3:5,15),as_factor))

data %>% write_rds(str_c("save_databases/detailed_sales_reports/",date_selection2[2,1],"_",date_selection2[2,2],".rds"))
Sys.sleep(1)

file.remove(str_c(dossier_temporaire,"/",list.files(dossier_temporaire)))

############################################################ R selenium quand j'utilise une fonction ########### fin de la fonction ici

webElem <- remDr$findElement(using = "xpath", '//*[@id="lbLogout"]')
webElem$sendKeysToElement(list(" ", key = "enter"))

write_rds(today(),"save_databases/detailed_sales_reports/last_update.rds")

remDr$close()
rD$server$stop()
rD$server$process

write_rds(today(),"save_databases/detailed_sales_reports/last_update.rds")
print("parfait update bien effectué")
}

