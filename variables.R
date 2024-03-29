library(googleAnalyticsR)
library(tidyverse)
library(googlesheets)
library(magrittr)
library(stringr)
library(httr)

# source("data_fetching.R")

## VARIABLES
SS_NAME = "Biites Audit"
SS_ACCOUNT_TITLE = "Account Overview"
SS_QUERYLIST_TITLE = "Query Parameters"
ACCOUNT_ID <- "79746685"
PROPERTY_ID <- paste0("UA-", ACCOUNT_ID, "-4")
VIEW_ID <- "134235444"
DATE_RANGE <- c("2019-06-01", "2019-06-15")

## AUTHENTICATION
ga_auth()
gs_auth()

## 
# output <- fetchData(VIEW_ID)

## pushData()

# pushData(wsTitle = SS_QUERYLIST_TITLE)
