# R code for downloading OpenAlex data on publications count
# for case of Russian institutions
# by D. Tereshchenko

# Loading packages =============================================================

library(rjson)
library(purrr)
library(tidyr)
library(dplyr)
library(readr)

# Take a glimpse at the data ===================================================

### First, I load a sample of 25 institutions that are on page 1 of the output. 
### I know how to filter institutions from 
### https://docs.openalex.org/api-entities/institutions/filter-institutions 
url0 <- "https://api.openalex.org/institutions?filter=country_code:ru"
page0 <- fromJSON(file = url0)

### I am particularly interested in the following variables.
### Unfortunately, they are on different levels of the lists. 
page0[["results"]][[1]][["display_name"]]
page0[["results"]][[1]][["type"]]
page0[["results"]][[1]][["works_count"]]
page0[["results"]][[1]][["cited_by_count"]]

page0[["results"]][[1]][["geo"]][["city"]]
page0[["results"]][[1]][["geo"]][["latitude"]]
page0[["results"]][[1]][["geo"]][["longitude"]]

page0[["results"]][[1]][["counts_by_year"]][[1]]

### I practiced converting nested lists into a dataset on this sample.
sample0 <- as.data.frame(do.call(rbind, page0[["results"]])) 

sample1 <- sample0 %>% 
  select(display_name, type, geo, counts_by_year) %>% 
  unnest(c(display_name, type)) %>%
  unnest(counts_by_year, keep_empty = TRUE) %>% # To overcome the first level of list
  unnest_wider(c(geo, counts_by_year), names_repair = "universal") %>%
  arrange(display_name, year) %>%
  select(display_name, year, type,
         works_count, cited_by_count, 
         city, longitude, latitude)

# Downloading the full dataset =================================================

### From "meta" list we can obtain the total number of institutions
institutions_count <- page0[["meta"]][["count"]]

### Maximum allowed institutions per page is 200 
per_page <- 200

### Update the URL for json-file page
url <- paste0(url0, "&per-page=", as.character(per_page))

### Calculate how many pages is needed to download full data set. 
pages_count <- ceiling(institutions_count / per_page) #=11
pages <- seq(1, pages_count, 1)

### Create a list of json-files
urls <- map(pages, \(x) paste0(url, "&page=", as.character(x)))
jsons <- map(urls, \(x) fromJSON(file = x))

### Convert json-files to data.frames
dfs <- map(jsons, \(x) as.data.frame(do.call(rbind, x[["results"]])))

### Bind data.frames
df0 <- bind_rows(dfs)

### Unnest columns that still contain lists
df1 <- df0 %>% 
  select(display_name, type, geo, counts_by_year) %>% 
  unnest(c(display_name, type)) %>%
  unnest(counts_by_year, keep_empty = TRUE) %>% 
  unnest_wider(c(geo, counts_by_year), names_repair = "universal") %>%
  arrange(display_name, year) %>%
  select(display_name, year, type,
         works_count, cited_by_count, 
         city, longitude, latitude)

### Check missing values in the data
df1 %>% summarise(across(everything(), \(x) sum(is.na(x))))

### There are some observations with missing data
### Probably it is better to remove it from the dataframe
df1 <- df1 %>% drop_na()


# Saving the data set ==========================================================

df1 %>% write_csv(paste0("openalex_ru_", Sys.Date() ,".csv"))

rm(list = ls())
