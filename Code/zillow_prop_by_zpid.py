import http.client
import pandas as pd
import json
from pandas import json_normalize

# Read the API key from the text file
api_key_file = r".../Code/rapidapi_key.txt"
with open(api_key_file, 'r') as file:
    rapidapi_key = file.read().strip()

# Define the API host
host = "zillow-com1.p.rapidapi.com"

# Initialize the connection
conn = http.client.HTTPSConnection(host)

# Define the headers
headers = {
    'x-rapidapi-key': rapidapi_key,
    'x-rapidapi-host': host
}

# Define the path to the CSV file
csv_path = r"...App/Data/zillow_properties.csv"

# Read the CSV file into a DataFrame
properties_df = pd.read_csv(csv_path)

# Extract the 'zpid' column and convert it to a list
zpid_list = properties_df['zpid'].tolist()

# Initialize a list to store the results
results = []

# Loop through the list of zpids and make API requests
for zpid in zpid_list:
    # Define the request URL for the current zpid
    request_url = f"/property?zpid={zpid}"
    
    # Make the GET request
    conn.request("GET", request_url, headers=headers)
    
    # Get the response
    res = conn.getresponse()
    data = res.read()
    
    # Decode the response data
    decoded_data = data.decode("utf-8")
    
    # Parse the JSON data
    json_data = json.loads(decoded_data)
    
    # Append the JSON data to the results list
    results.append(json_data)
    
    # Print the JSON data for debugging
    print(json.dumps(json_data, indent=2))

# Close the connection
conn.close()

# Convert the list of JSON responses to a DataFrame
results_df = json_normalize(results)
results_df
# # Define the path to save the CSV
csv_path_results = r"...App/Data/property_details.csv"

# Save the DataFrame to a CSV file
results_df.to_csv(csv_path_results, index=False)

print(f"Property details saved to {csv_path_results}")