# R code for downloading OpenAlex data on publications count (for case of Russian institutions)

For my research on publication activity in Russia, I want to try data from the [OpenAlex project](https://openalex.org/). 

In script `openalex-rus-acquise.R` I load data from the project website in json format and convert it into a flat dataset. The result is a long-format panel data with the number of publications and citations by year for each university. 

The main challenges of working with data: 
- diving into the OpenALex data work format and loading json-format,
- converting nested lists derived from a json file into a flat dataset. 

In script `openalex-rus-regions.R` I aggregate OpenAlex data on subnational level for regions of Russia using geographical coordinates of instituions provided by OpenAlex in combination with geospatial dataframes of Russian regions [created by me previously](https://github.com/dtereshch/rus-reg-80-spatial). 
