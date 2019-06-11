source("variables.R")

## Create new SS
gs_new(title = SS_NAME)
ss <- gs_title(SS_NAME)

## Create Acount Overview with views
fetch_accounts <- function(acId) {
            ga_account_list() %>%
              filter(accountId == acId) %>% 
              select(accountName, 
                     accountId, 
                     webPropertyName, 
                     webPropertyId, 
                     viewName, 
                     viewId)
  
            colnames(ac_list) <- c("Account Name", "Account ID", "Property Name", "Property ID", "View Name", "View ID")
  
}

ac_list <- fetch_accounts(ACCOUNT_ID)

## Input account overview
ss %>% gs_ws_new(ws_title = SS_ACCOUNT_TITLE , input = ac_list)

## Get Page Report from Roll-up account
fetchData <- function(VIEW_ID) {
  out <- tryCatch(
    {
      message("Fetching data...")
      df <- google_analytics(viewId = VIEW_ID, 
                             date_range = DATE_RANGE, 
                             dimensions = c("hostname", "pagePath"), 
                             metrics = "pageviews", 
                             anti_sample = TRUE)
      
      ## QUERY PARAMETERS
      df_q <- df %>% filter(!grepl("not set", hostname))
      df_q %<>% filter(grepl("(\\?|&)", pagePath))
      
      ## change sapply, map_df() purrr
      
      ll <- sapply(df_q$pagePath, function(x) parse_url(x)$query %>% unlist() %>% names()) %>% unlist()
      
      ll %<>% tbl_df()
      
      colnames(ll) <- "Query"
      
      ll %>% group_by(Query) %>% tally() %>% mutate(share = n/sum(n)*100) %>% arrange(-n)
    }, 
    error=function(cond) {
      message("Found no queryparameters in the URLS")
      return(NA)
    }
  )
}

## try catch
## testthat


output <- fetchData(VIEW_ID)

pushData <- function(wsTitle){
  ss %>% gs_ws_new(ws_title = wsTitle, input = output)
}

pushData()


## HOSTNAME DATA

hostname <-  google_analytics(viewId = VIEW_ID, 
                       date_range = DATE_RANGE, 
                       dimensions = c("hostname"), 
                       metrics = "pageviews", 
                       anti_sample = TRUE)
colnames(hostname) <- c("Hostname", "Pageviews")



pushData()

ss %>% gs_ws_delete(ws = 1)

# gs_delete(ss)

gs_browse(ss)