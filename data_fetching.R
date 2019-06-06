library(googleAnalyticsR)
library(tidyverse)
library(googlesheets)
library(magrittr)
library(stringr)
library(httr)

## SOURCE VARIABLES
source("variables.R")

## AUTHENTICATION
ga_auth()
gs_auth()

## Create new SS
gs_new(title = SS_NAME)
ss <- gs_title(SS_NAME)

## Create Acount Overview with views
ac_list <- ga_account_list() %>% filter(accountId == ACCOUNT_ID)
## Input account overview
ss %>% gs_ws_new(ws_title = SS_ACCOUNT_TITLE , input = ac_list)

## Get Page Report from Roll-up account
fetchData <- function(ACCOUNT_ID, PROPERTY_ID, VIEW_ID) {
  
  ga_view(accountId = ACCOUNT_ID, webPropertyId = PROPERTY_ID, profileId = VIEW_ID)
  
  df <- google_analytics(viewId = VIEW_ID, 
                         date_range = DATE_RANGE, 
                         dimensions = c("hostname", "pagePath"), 
                         metrics = "pageviews", 
                         anti_sample = TRUE)
  df
  ## ANALYSIS
  df_q <- df %>% filter(!grepl("not set", hostname))
  df_q %<>% filter(grepl("(\\?|&)", pagePath))
  
  ll <- sapply(df_q$pagePath, function(x) parse_url(x)$query %>% unlist() %>% names()) %>% unlist()
  ll %<>% tbl_df()
  colnames(ll) <- "Query"
  ll
  outp <- ll %>% group_by(Query) %>% tally() %>% mutate(share = n/sum(n)*100) %>% arrange(-n)
  
  return(outp)
}

output <- fetchData(ACCOUNT_ID, PROPERTY_ID, VIEW_ID)

pushData <- function(){
  ss %>% gs_ws_new(ws_title = SS_QUERYLIST_TITLE, input = output)
}

pushData()

gs_browse(ss)
