fct_detailed_sales <- function(mois,annee){
  mois <- 6
  annee <- 2022
  
  remDr$close()
  rD$server$stop()
  
ma_date <- make_date(year = annee,month = mois,day = 1)
debut <-   format(ma_date, "%m/%d/%Y")
fin <-   format(ma_date + dmonths(1)- ddays(1),"%m/%d/%Y")
  
#wd <- getwd()
#cprof <- getChromeProfile(wd, "Profile 1")
#remDr <- remoteDriver(browserName= "chrome", extraCapabilities = cprof) 

remDr <- remoteDriver(
  remoteServerAddr = "localhost",
  port = 4445L,
  browserName = "chrome"
)


file_path <- str_c(getwd() %>% str_replace_all("/", "\\\\\\"),"\\temp_download")

eCaps <- list(
  chromeOptions =
    list(prefs = list('download.default_directory' = file_path))
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
webElem$sendKeysToElement(list("Detailed Sales"))
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
webElem <- remDr$findElement(using = "xpath", '//*[@id="ucReportBuilder_tblParamas"]/tbody/tr/td[1]/table/tbody/tr[2]/td[1]/select')
webElem$sendKeysToElement(list("<ALL>"))
webElem <- remDr$findElement(using = "xpath", '//*[@id="ucReportBuilder_tblParamas"]/tbody/tr/td[1]/table/tbody/tr[2]/td[2]/input[1]')
webElem$sendKeysToElement(list(" ", key = "enter"))
webElem <- remDr$findElement(using = "xpath", '//*[@id="ucReportBuilder_cmdCreateReport"]')
webElem$sendKeysToElement(list(" ", key = "enter"))

Sys.sleep(10)

remDr$close()
rD$server$stop()
#rD$server$process
}
