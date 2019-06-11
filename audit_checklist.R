

fetch_data <- function(dim, met){
  
  google_analytics(viewId = VIEW_ID, 
                       date_range = DATE_RANGE, 
                       dimensions = c(dim), 
                       metrics = met, 
                       anti_sample = TRUE)
  
}

## Direct Traffic
direct_traffic <- function(){
df <- fetch_data("sourceMedium", "pageViews")
df %<>% arrange(-pageViews) %>% mutate(share = pageViews/sum(pageViews)) %>% filter(sourceMedium == "(direct) / (none)")
if (df$share > 0.15) {
  print(paste0("Direct traffic is above average: ", percent(df$share), " of total traffic"))
} else {
  "Low level"
}
}

direct_traffic()

## BounceRate check
bounce_rate <- function() {
  df <- fetch_data(c("landingPagePath", "sourceMedium"), c("bounceRate", "pageViews"))
  df %<>% mutate(share = pageViews/sum(pageViews)) %>% filter(share > 0.001) %>% arrange(-pageViews)
}

bounce_rate()

## Personal Identifiable Information
pii <- function() {
  df <- fetch_data("pagePath", "pageViews")
  df %<>% filter(grepl("@", pagePath))
  
  if (length(df$pagePath) == 0) {
    print("No PII found")
  } else {
    message("PII found:")
    return(df)
  }
}

pii()

## Channel Distribution

channel_distribution <- function() {
  df <- fetch_data("")
}






