# R code for aggregating OpenAlex data on publications count
# at subnational level (case of Russian regions)
# by D. Tereshchenko

# Setup ========================================================================

## Packages --------------------------------------------------------------------

library(readr)
library(dplyr)
library(tidyr)
library(sf)
library(lwgeom)

## Other -----------------------------------------------------------------------

sf_use_s2(FALSE)      # fixes some problems: https://gis.stackexchange.com/questions/404385/r-sf-some-edges-are-crossing-in-a-multipolygon-how-to-make-it-valid-when-using


# Loading the data =============================================================

## OpenAlex data ---------------------------------------------------------------

oa_inst <- read_csv("openalex_ru_2024-06-20.csv") ### Choose dataset needed 


## Spatial dataframes for Russian regions --------------------------------------

## Load two dataframes containing data fro 83 and 80 Russian regions
load("rus_reg_sf.RData") # For details see https://github.com/dtereshch/rus-reg-80-spatial

### Check geospatial dfs
mean(st_is_valid(rus_reg_sf))
rus_reg_sf[!st_is_valid(rus_reg_sf),]

mean(st_is_valid(rus_reg_sf_80))
rus_reg_sf_80[!st_is_valid(rus_reg_sf_80),]

### Presumably the error is due to the projection transformation 
### required to construct adequate maps
### Probably setting sf_use_s2(FALSE) solves the problem
st_crs(rus_reg_sf)
st_crs(rus_reg_sf_80)


# Joining dataframes ===========================================================

## Spatial join ----------------------------------------------------------------

### Convert OpenAlex data to spatial df
oa_inst_sf <- st_as_sf(x = oa_inst, 
                       coords = c("longitude", "latitude"), 
                       crs = 4326) %>% 
  st_transform_proj(crs = "+proj=longlat +lon_wrap=180")

mean(sf::st_is_valid(oa_inst_sf))

### Add region column to the OpenAlex data frame
oa_inst_reg <- oa_inst_sf %>% 
  st_join(rus_reg_sf["NAME_1"], join = st_intersects, left = TRUE) %>%
  rename(region_shp = NAME_1)


## Aggregate data at the regional level ----------------------------------------

oa_reg <- oa_inst_reg %>% 
  st_drop_geometry() %>%
  full_join(rus_reg_sf["NAME_1"], by = c("region_shp" = "NAME_1")) %>% # add Chukotka
  group_by(region_shp, year, type) %>%
  summarise(works_count = sum(works_count, na.rm = TRUE),
            cited_by_count = sum(cited_by_count, na.rm = TRUE),
            inst_count = n()) %>%
  ungroup()

### create complete dataset with all possible combinations of `region_shp`, `year`, and `type`
oa_reg_comp <- oa_reg %>% complete(region_shp, year, type)


### Do the same for spatial dataframe with 80 instead of 83 Russian regions
### For details see https://github.com/dtereshch/rus-reg-80-spatial
oa_inst_reg_80 <- oa_inst_sf %>% 
  st_join(rus_reg_sf_80["NAME_1"], join = st_intersects, left = TRUE) %>%
  rename(region_shp = NAME_1)

oa_reg_80 <- oa_inst_reg_80 %>% 
  st_drop_geometry() %>%
  full_join(rus_reg_sf["NAME_1"], by = c("region_shp" = "NAME_1")) %>% # add Chukotka
  group_by(region_shp, year, type) %>%
  summarise(works_count = sum(works_count, na.rm = TRUE),
            cited_by_count = sum(cited_by_count, na.rm = TRUE),
            inst_count = n()) %>%
  ungroup()

oa_reg_80_comp <- oa_reg_80 %>% complete(region_shp, year, type)

## Save data ===================================================================

oa_inst_reg %>% write_csv(paste0("openalex_ru_w_reg_", Sys.Date() ,".csv"))
oa_reg_comp %>% write_csv(paste0("openalex_rus_reg_", Sys.Date() ,".csv"))
oa_reg_80_comp %>% write_csv(paste0("openalex_rus_reg_80_", Sys.Date() ,".csv"))

rm(list = ls())
