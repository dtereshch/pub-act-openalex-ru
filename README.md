# R code for downloading OpenAlex data on publications count (for case of Russian institutions)

For my research on publication activity in Russia, I want to try data from the [OpenAlex project](https://openalex.org/). 

## Scripts

In script `openalex-rus-acquise.R` I load data from the project website in json format and convert it into a flat dataset. The result is a long-format panel data with the number of publications and citations by year for each university. 

The main challenges of working with data: 
- diving into the OpenALex data work format and loading json-format,
- converting nested lists derived from a json file into a flat dataset. 

In script `openalex-rus-regions.R` I aggregate OpenAlex data on subnational level for regions of Russia using geographical coordinates of instituions provided by OpenAlex in combination with geospatial dataframes of Russian regions [created by me previously](https://github.com/dtereshch/rus-reg-80-spatial). 

## Datasets 

- Datasets with names starting with "openalex_ru_" are long panels containing OpenAlex data at intitutions level. 

- Datasets with names starting with "openalex_ru_w_reg_" are long panels containing OpenAlex data at intitutions level with added region column. 

- Datasets with names starting with "openalex_rus_reg_" are long panels with OpenAlex data aggregated at regional level

- Datasets with names starting with "openalex_rus_reg_80_" are long panels with OpenAlex data aggregated at regional level for 80 regions instead of 83 region. The Nenets Autonomous District is accounted for as part of the Arkhangelsk Region, and the Khanty-Mansiysk and Yamalo-Nenets Autonomous Districts are accounted for as part of the Tyumen Region ([details](https://github.com/dtereshch/rus-reg-80-spatial)).

## Variables

- display_name: name of the institution
- year: year
- type: type of the instituion
- works_count: number of works
- cited_by_count: number of citations
- city: city
- geometry: geospatial data
- region_shp: name of region originaly used in shp-files at [gadm.org](https://gadm.org/data.html)