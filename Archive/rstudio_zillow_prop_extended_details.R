library(httr)

url <- "https://zillow-com1.p.rapidapi.com/propertyExtendedSearch"
host <- 'zillow-com1.p.rapidapi.com'
rapidapi <- 'b7f302bafamsh8f4dd2dde0d7451p1e9ccajsn90a3b9a8be35'

queryString <- list(
  location = "ct",
  status_type = "RecentlySold",
  home_type = "Houses",
  bathsMin = "2",
  bedsMin = "3",
  soldInLast = "36m",
  maxPrice = "700000",
  isForSaleForeclosure = "false"
)


response <- VERB("GET", url, query = queryString, add_headers('x-rapidapi-key' = rapidapi, 'x-rapidapi-host' = host), content_type("application/octet-stream"))
 
 content(response, "parsed")

 # 


library(httr)

url <- "https://zillow-com1.p.rapidapi.com/propertyExtendedSearch"
host <- 'zillow-com1.p.rapidapi.com'
rapidapi <- '2c34f2ea56msh53f8eac5c364399p1b66a1jsnfc2467559f05'

queryString <- list(
  location = "ct",
  page = "20",
  status_type = "RecentlySold",
  home_type = "Houses, Condos, Townhomes",
  minPrice = "100000",
  maxPrice = "700000",
  soldInLast = "36m",
  isForSaleForeclosure = "false"
)

response <- VERB("GET", url, query = queryString, add_headers(
  'x-rapidapi-key' = rapidapi,
  'x-rapidapi-host' = host
), content_type("application/octet-stream"))

# Check the status of the response
if (http_status(response)$category == "Success") {
  content_response <- content(response, "parsed")
  print(content_response)
} else {
  print(paste("Failed to get data. Status code:", http_status(response)$status))
}

# install -----------------------------------------------------------------

install.packages("jsonlite", "dplyr", "tidyr")


library(httr)
library(jsonlite)
library(dplyr)
library(tidyr)

url <- "https://zillow-com1.p.rapidapi.com/propertyExtendedSearch"
host <- 'zillow-com1.p.rapidapi.com'
rapidapi <- '2c34f2ea56msh53f8eac5c364399p1b66a1jsnfc2467559f05'

queryString <- list(
  location = "bridgeport, ct",
  page = "20",
  status_type = "RecentlySold",
  home_type = "Houses, Condos, Townhomes",
  minPrice = "100000",
  maxPrice = "700000",
  soldInLast = "36m",
  isForSaleForeclosure = "false"
)

response <- VERB("GET", url, query = queryString, add_headers(
  'x-rapidapi-key' = rapidapi,
  'x-rapidapi-host' = host
), content_type("application/octet-stream"))

# Check the status of the response
if (http_status(response)$category == "Success") {
  content_response <- content(response, "parsed")
  
  # Convert the parsed content to a dataframe
  properties <- content_response$props %>% as_tibble()
  
  # Define the path to save the CSV
  csv_path <- "C:/Users/mitchele/University of Iowa/Dedas, Jason M - Analytics Experience Group 2/Code/zillow_properties.csv"
  
  # Save the dataframe to a CSV file
  write.csv(properties, csv_path, row.names = FALSE)
  
  print(paste("Data saved to", csv_path))
} else {
  print(paste("Failed to get data. Status code:", http_status(response)$status))
}


Rscript -e "install.packages('purrr', repos='http://cran.rstudio.com/')"
