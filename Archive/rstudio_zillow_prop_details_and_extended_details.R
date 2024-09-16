library(httr)
library(jsonlite)

# Read the API key from the text file
api_key_file <- "C:/Users/YOUR_USERNAME/University of Iowa/Dedas, Jason M - Analytics Experience Group 2/Code/rapidapi_key.txt"
rapidapi <- readLines(api_key_file, warn = FALSE)

# Define the URLs and headers
url <- "https://zillow-com1.p.rapidapi.com/propertyExtendedSearch"
url1 <- "https://zillow-com1.p.rapidapi.com/property"
host <- 'zillow-com1.p.rapidapi.com'

# Define the first query string to get ZPIDs
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

# Make the first API call to get ZPIDs
response <- VERB("GET", url, query = queryString, add_headers(
  'x-rapidapi-key' = rapidapi,
  'x-rapidapi-host' = host
), content_type("application/octet-stream"))

# Check the response status
if (status_code(response) == 200) {
  # Parse the response content to extract ZPIDs
  content_response <- content(response, "parsed")
  str(content_response) # Inspect the structure of the response
  
  # Extract valid results
  results <- content_response$results
  valid_results <- results[sapply(results, is.list)]
  
  # Extract ZPIDs
  zpids <- sapply(valid_results, function(x) x$zpid)
  
  # Extract and convert dateSold from milliseconds to Date format
  date_sold <- sapply(valid_results, function(x) {
    if (is.numeric(x$dateSold)) {
      as.POSIXct(x$dateSold / 1000, origin="1970-01-01")
    } else {
      NA
    }
  })
  
  # Combine ZPIDs and dateSold into a data frame
  property_info <- data.frame(zpid = zpids, dateSold = date_sold, stringsAsFactors = FALSE)
  
  # Initialize a list to store detailed property information
  property_details <- list()
  
  # Loop through each ZPID and make the second API call to get detailed property information
  for (zpid in zpids) {
    queryString1 <- list(zpid = zpid)
    
    response1 <- VERB("GET", url1, query = queryString1, add_headers(
      'x-rapidapi-key' = rapidapi,
      'x-rapidapi-host' = host
    ), content_type("application/octet-stream"))
    
    # Check the response status
    if (status_code(response1) == 200) {
      # Parse the response content
      property_detail <- content(response1, "parsed")
      # Add zpid and dateSold to the property_detail
      property_detail$zpid <- zpid
      property_detail$dateSold <- date_sold[which(zpids == zpid)]
      # Append the detailed property information to the list
      property_details <- append(property_details, list(property_detail))
    } else {
      print(paste("Failed to get details for ZPID:", zpid))
    }
  }
  
  # Convert the list of property details to a dataframe
  property_df <- do.call(rbind, lapply(property_details, function(x) as.data.frame(x, stringsAsFactors = FALSE)))
  
  # Print the detailed property information as dataframe
  print(property_df)
} else {
  print("Failed to get ZPIDs")
}
