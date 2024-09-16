library(httr)

url <- "https://zillow-com1.p.rapidapi.com/propertyExtendedSearch"
host <- 'zillow-com1.p.rapidapi.com'
rapidapi <- '2c34f2ea56msh53f8eac5c364399p1b66a1jsnfc2467559f05'

queryString <- list(
  location = "ct",
  page = "1-20",
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

# Define the path to save the CSV
csv_path <- "C:/Users/mitchele/University of Iowa/Dedas, Jason M - Analytics Experience Group 2/Code/zillow_properties.csv"

# Save the dataframe to a CSV file
write.csv(properties, csv_path, row.names = FALSE)

# install -----------------------------------------------------------------

install.packages("jsonlite", "dplyr", "tidyr")


import requests
import json
import pandas as pd

# Read the API key from the text file
api_key_file = r"C:\Users\mitchele\University of Iowa\Dedas, Jason M - Analytics Experience Group 2\Code\rapidapi_key.txt"
with open(api_key_file, 'r') as file:
  rapidapi_key = file.read().strip()

# Define the URL and headers
url = "https://zillow-com1.p.rapidapi.com/propertyExtendedSearch"
headers = {
  'x-rapidapi-key': rapidapi_key,
  'x-rapidapi-host': 'zillow-com1.p.rapidapi.com',
  'Content-Type': 'application/octet-stream'
}

# Initialize an empty list to store all property details
all_properties = []

# Loop through pages 1 to 20
for page in range(1, 21):
  # Define the query parameters for the current page
  queryString = {
    "location": "ct",
    "page": str(page),  # Convert page number to string
    "status_type": "RecentlySold",
    "home_type": "Houses,Condos,Townhomes",  # Ensure no spaces after commas
    "minPrice": "100000",
    "maxPrice": "700000",
    "soldInLast": "36m",
    "isForSaleForeclosure": "false"
  }

# Make the GET request
response = requests.get(url, headers=headers, params=queryString)

# Check if the response status is OK (200)
if response.status_code == 200:
  # Parse the response content
  content_response = response.json()

# Debugging: Print the raw content response
print(f"Raw content response for page {page}:")
print(json.dumps(content_response, indent=2))

if 'props' in content_response and len(content_response['props']) > 0:
  # Append the properties to the all_properties list
  all_properties.extend(content_response['props'])
else:
  print(f"No properties found on page {page}.")
else:
  print(f"Failed to get data for page {page}. Status code: {response.status_code}")

# Convert the list of all properties to a DataFrame
properties_df = pd.DataFrame(all_properties)

# Define the path to save the CSV
csv_path = r"C:/Users/mitchele/University of Iowa/Dedas, Jason M - Analytics Experience Group 2/Data/zillow_properties.csv"

# Save the DataFrame to a CSV file
properties_df.to_csv(csv_path, index=False)

print(f"Data saved to {csv_path}")
