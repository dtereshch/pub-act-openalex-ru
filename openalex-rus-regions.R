# R code for aggregating OpenAlex data on publications count
# at subnational level (case of Russian regions)
# by D. Tereshchenko

# Loading packages =============================================================

library(readr)
library(dplyr)
library(sf)
library(lwgeom)

# Loading the OpenAlex data ====================================================

### Choose and load dataset needed 
oa_inst <- read_csv("openalex_ru_2024-03-28.csv")
oa_inst_compl <- oa_inst %>% drop_na()



## Loading shp-file for Russian regions ----------------------------------------
rus_shp <- st_read(paste0(shp_path, "gadm36_RUS_1.shp"), crs = 4326, quiet = TRUE)
# rus_shp <- st_read(paste0(shp_path, "gadm36_RUS_1.shp"), crs = 4326, quiet = TRUE) %>% 
#   st_transform_proj(crs = "+proj=longlat +lon_wrap=180") %>% 
#   arrange(NAME_1)

## Spatial join ----------------------------------------------------------------
oa_inst_sp <- st_as_sf(x = oa_inst_compl, 
                       coords = c("longitude", "latitude"), 
                       crs = 4326)
# oa_inst_sp <- st_as_sf(x = oa_inst_compl, 
#                        coords = c("longitude", "latitude"), 
#                        crs = 4326) %>%
#   st_transform_proj(crs = "+proj=longlat +lon_wrap=180")

mean(sf::st_is_valid(rus_shp))
mean(sf::st_is_valid(oa_inst_sp))
#rus_shp[!sf::st_is_valid(rus_shp),]

oa_inst_reg <- st_join(oa_inst_sp, rus_shp["NAME_1"], join = st_intersects, left = TRUE)

## Regions dataset -------------------------------------------------------------
#number <- function(x, na.rm = TRUE){return(sum(!is.na(x)))}

oa_reg <- oa_inst_reg %>% 
  st_drop_geometry() %>%
  rename(region_shp = NAME_1) %>%
  group_by(region_shp, year, type) %>%
  summarise(works_count = sum(works_count, na.rm = TRUE),
            cited_by_count = sum(cited_by_count, na.rm = TRUE),
            inst_count = n()) %>%
  ungroup()

oa_edu_reg <- oa_reg %>% filter(type == "education") %>% select(-type)