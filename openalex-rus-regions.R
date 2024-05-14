# R code for aggregating OpenAlex data on publications count
# at subnational level (case of Russian regions)
# by D. Tereshchenko

# Setup ========================================================================

## Packages --------------------------------------------------------------------

library(readr)
library(dplyr)
library(sf)
library(lwgeom)

## Other -----------------------------------------------------------------------

sf_use_s2(FALSE)      # fixes some problems: https://gis.stackexchange.com/questions/404385/r-sf-some-edges-are-crossing-in-a-multipolygon-how-to-make-it-valid-when-using


# Loading the data =============================================================

## OpenAlex data ---------------------------------------------------------------

oa_inst <- read_csv("openalex_ru_2024-05-14.csv") ### Choose dataset needed 


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
st_crs(rus_reg_sf)
st_crs(rus_reg_sf_80)

### Change crs
rus_reg_sf <- rus_reg_sf %>% st_set_crs(4326)
rus_reg_sf_80 <- rus_reg_sf_80 %>% st_set_crs(4326)

mean(st_is_valid(rus_reg_sf))
mean(st_is_valid(rus_reg_sf_80))

# Joining dataframes ===========================================================

## Spatial join ----------------------------------------------------------------

### Convert OpenAlex data to spatial df
oa_inst_sf <- st_as_sf(x = oa_inst, 
                       coords = c("longitude", "latitude"), 
                       crs = 4326) %>% st_transform_proj(crs = "+proj=longlat +lon_wrap=180")

mean(sf::st_is_valid(oa_inst_sf))

### Add region column to the OpenAlex data frame
oa_inst_reg <- st_join(oa_inst_sf, rus_reg_sf["NAME_1"], join = st_intersects, left = TRUE)

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