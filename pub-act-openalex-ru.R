library(rjson)
library(purrr)
library(tidyr)
library(dplyr)
#library(data.table)

url0 <- "https://api.openalex.org/institutions?filter=country_code:ru"
page0 <- fromJSON(file = url0)

page0[["results"]][[1]][["display_name"]]
page0[["results"]][[1]][["type"]]
page0[["results"]][[1]][["works_count"]]
page0[["results"]][[1]][["cited_by_count"]]

page0[["results"]][[1]][["geo"]][["city"]]
page0[["results"]][[1]][["geo"]][["latitude"]]
page0[["results"]][[1]][["geo"]][["longitude"]]

page0[["results"]][[1]][["counts_by_year"]][[1]]

as.data.frame(page0[["results"]][[1]][["counts_by_year"]][[1]])
# map(page0[["results"]], as.data.table)
# 
# dt_list <- map(page0[["results"]], as.data.table)
# dt <- rbindlist(dt_list, fill = TRUE, idcol = T)

df0 <- as.data.frame(do.call(rbind, page0[["results"]])) 

df1 <- df0 %>% 
  select(display_name, type, geo, counts_by_year) %>% 
  unnest(counts_by_year) %>% 
  unnest_wider(c(geo, counts_by_year), names_repair = "universal") %>%
  arrange(display_name, year) %>%
  select(display_name, year, 
         works_count, cited_by_count, 
         city, longitude, latitude)




institutions_count <- page0[["meta"]][["count"]]
per_page <- 200 # max allowed by OA
pages_count <- ceiling(institutions_count / per_page)
pages <- seq(1, pages_count, 1)


url <- paste0(url0, "&per-page=", as.character(per_page))
urls <- map(pages, \(x) paste0(url, "&page=", as.character(x)))
jsons <- map(urls, \(x) fromJSON(file = x))
jsons_res <- map(jsons, \(x) x[["results"]])

#bind_rows
#see above




