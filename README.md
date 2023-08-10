# R code for downloading OpenAlex data on publications count (for case of Russian institutions)

For my research on publication activity in Russia, I want to try data from the [OpenAlex project](https://openalex.org/). In this script I load data from the project website in json format and convert it into a flat dataset. The result is a long-format panel data with the number of publications and citations by year for each university. 

The main challenges of working with data: 
- diving into the OpenALex data work format and loading json-format,
- converting nested lists derived from a json file into a flat dataset. 
