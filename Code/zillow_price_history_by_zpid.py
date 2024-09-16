# breakout the price history into individual rows and produce a csv
import pandas as pd
import json
import re
from bs4 import BeautifulSoup
from datetime import datetime

# Define the paths for input and output CSV files
# Full file path hidden
csv_path = r"...App/Data/zillow_property_details_combined.csv"
output_csv_path = r"...App/Data/zillow_price_history_by_zpid.csv"

# Read the CSV file into a DataFrame
properties_df = pd.read_csv(csv_path, low_memory=False)

# Select columns for review
prop_df = properties_df[['zpid', 'priceHistory']].copy()

# Define a function to aggressively clean JSON strings
def clean_json_string(s):
    if isinstance(s, str):
        # Use BeautifulSoup to clean up the string
        s = BeautifulSoup(s, "html.parser").text
        # Replace single quotes with double quotes
        s = s.replace("'", '"')
        # Replace None with null
        s = s.replace('None', 'null')
        # Replace true/false with True/False
        s = s.replace('true', 'True').replace('false', 'False')
        # Remove control characters
        s = re.sub(r'[\x00-\x1f\x7f-\x9f]', '', s)
        # Remove any unnecessary whitespace
        s = s.strip()
        # Remove known nested structures
        s = re.sub(r'"sellerAgent":\s*{[^{}]*},', '', s)
        s = re.sub(r'"buyerAgent":\s*{[^{}]*},', '', s)
        s = re.sub(r'"attributeSource":\s*{[^{}]*},', '', s)
        # Remove extra commas before closing brackets
        s = re.sub(r',\s*]', ']', s)
        s = re.sub(r',\s*}', '}', s)
        return s
    return s

def safe_json_loads(s):
    if pd.isna(s):
        return None
    try:
        s = clean_json_string(s)
        return json.loads(s)
    except json.JSONDecodeError as e:
        # Log the error for debugging
        print(f"JSONDecodeError: {e} for string: {s}")
        with open("debug_log.txt", "a") as f:
            f.write(f"JSONDecodeError: {e} for string: {s}\n")
        return None

def convert_time_to_date(t):
    if isinstance(t, (int, float)):
        return datetime.fromtimestamp(t / 1000).strftime('%Y-%m-%d')
    return t

# Apply the function to the 'priceHistory' column using .loc to avoid SettingWithCopyWarning
prop_df.loc[:, 'priceHistory'] = prop_df['priceHistory'].apply(safe_json_loads)

# Print to check the first few rows after parsing JSON
print("After JSON parsing:")
print(prop_df.head(10))  # Limit to first 10 rows for debugging

# Remove rows where JSON parsing failed
prop_df = prop_df.dropna(subset=['priceHistory'])

# Print to check the DataFrame after dropping NaNs
print("After dropping NaNs:")
print(prop_df.head(10))  # Limit to first 10 rows for debugging

# Expand the JSON in the 'priceHistory' column
price_history_expanded_df = prop_df.explode('priceHistory')

# Print to check the expanded DataFrame
print("After expanding JSON:")
print(price_history_expanded_df.head(10))  # Limit to first 10 rows for debugging

# Function to extract specific fields from priceHistory, ignoring nested structures
def extract_fields(price_history_item):
    if isinstance(price_history_item, dict):
        return {
            'date': price_history_item.get('date'),
            'event': price_history_item.get('event'),
            'priceChangeRate': price_history_item.get('priceChangeRate'),
            'price': price_history_item.get('price'),
            'pricePerSquareFoot': price_history_item.get('pricePerSquareFoot')
        }
    return None

# Apply the function to extract specific fields
price_history_expanded_df['priceHistory'] = price_history_expanded_df['priceHistory'].apply(extract_fields)

# Create a DataFrame with normalized JSON data
price_history_normalized_df = pd.json_normalize(price_history_expanded_df['priceHistory'])

# Combine the zpid and normalized priceHistory data
result_df = price_history_expanded_df[['zpid']].reset_index(drop=True).join(price_history_normalized_df)

# Display the result
print("Final result:")
print(result_df.head(10))  # Limit to first 10 rows for debugging

# Save the result to a new CSV file
result_df.to_csv(output_csv_path, index=False)

print(f"Data has been saved to {output_csv_path}")
