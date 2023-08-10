library(rjson)
library(purrr)

url0 <- "https://api.openalex.org/institutions?filter=country_code:ru"
page0 <- fromJSON(file = url0)
institutions_count <- page0[["meta"]][["count"]]
per_page <- 200 # max allowed by OA
pages_count <- ceiling(institutions_count / per_page)
pages <- seq(1, pages_count, 1)
url <- paste0(url0, "&per-page=", as.character(per_page))
urls <- map(pages, \(x) paste0(url, "&page=", as.character(x)))
jsons <- map(urls, \(x) fromJSON(file = x))
jsons_res <- map(jsons, \(x) x[["results"]])




openalex_ru[["results"]][[1]][["display_name"]]
openalex_ru[["results"]][[1]][["type"]]
openalex_ru[["results"]][[1]][["works_count"]]
openalex_ru[["results"]][[1]][["cited_by_count"]]

openalex_ru[["results"]][[1]][["geo"]][["city"]]
openalex_ru[["results"]][[1]][["geo"]][["latitude"]]
openalex_ru[["results"]][[1]][["geo"]][["longitude"]]

openalex_ru[["results"]][[1]][["counts_by_year"]][[1]]

