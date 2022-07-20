library(httr)
library(rvest)
library(tidyverse)
library(RSelenium)
library(lubridate)

#https://towardsdatascience.com/web-scraping-with-r-easier-than-python-c06024f6bf52
#https://riptutorial.com/r/example/23955/using-rvest-when-login-is-required
#https://adventuresindata.netlify.app/post/2018-01-17-viewing-rvest-sessions/
#https://jakobtures.github.io/web-scraping/  (book)
#https://thatdatatho.com/tutorial-web-scraping-rselenium/

fct_OTP_report <- function(mois,annee){

  jour <- 18
  mois <- 07
  annee <- 2022

  remDr$close()
  rD$server$stop()

ma_date <- make_date(year = annee,month = mois,day = jour)
debut <-   format(ma_date, "%m/%d/%Y")
fin <-   format(ma_date + dmonths(2)+ ddays(7),"%m/%d/%Y")

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
Sys.sleep(5)

# une fois connecter
webElem <- remDr$findElement(using = "xpath", '//*[(@id = "ucReportBuilder_reports")]')
webElem$sendKeysToElement(list("Load Factor"))
Sys.sleep(3)

webElem <- remDr$findElement(using = "xpath", '//*[(@id = "ucReportBuilder_dtm_from_date")]')
webElem$clearElement()

webElem$sendKeysToElement(list(debut))
webElem <- remDr$findElement(using = "xpath", '//*[(@id = "ucReportBuilder_dtm_to_date")]')
webElem$clearElement()
webElem$sendKeysToElement(list(fin))
webElem <- remDr$findElement(using = "xpath", '//*[(@id = "ucReportBuilder_format")]')
webElem$sendKeysToElement(list("CSV"))

#############
webElem <- remDr$findElement(using = "xpath", '//*[@id="ucReportBuilder_tblParamas"]/tbody/tr[2]/td[1]/table/tbody/tr[2]/td[1]/select')
webElem$sendKeysToElement(list("<ALL>"))
webElem <- remDr$findElement(using = "xpath", '//*[@id="ucReportBuilder_tblParamas"]/tbody/tr[2]/td[1]/table/tbody/tr[2]/td[2]/input[1]')
webElem$sendKeysToElement(list(" ", key = "enter"))
webElem <- remDr$findElement(using = "xpath", '//*[@id="ucReportBuilder_cmdCreateReport"]')
webElem$sendKeysToElement(list(" ", key = "enter"))

Sys.sleep(10)

remDr$close()
rD$server$stop()
rD$server$process
}

