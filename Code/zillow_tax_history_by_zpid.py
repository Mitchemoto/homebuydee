# extract the school information by zpid and produce a csv that is easily readable. 
import pandas as pd
import json
from bs4 import BeautifulSoup
import re
from datetime import datetime

# Define the paths for input and output CSV files
csv_path = r"...App/Data/zillow_property_details_combined.csv"
output_csv_path = r"...App/Data/zillow_tax_history_by_zpid.csv"

# Read the CSV file into a DataFrame
properties_df = pd.read_csv(csv_path, low_memory=False)

# Select columns for review
prop_df = properties_df[['zpid', 'taxHistory']].copy()

# Define a function to aggressively clean JSON strings
def clean_json_string(s):
    if isinstance(s, str):
        # Use BeautifulSoup to clean up the string
        s = BeautifulSoup(s, "html.parser").text
        # Replace single quotes with double quotes
        s = s.replace("'", '"')
        # Replace None with null
        s = s.replace('None', 'null')
        # Remove any unnecessary whitespace
        s = s.strip()
        # Fix unescaped internal double quotes by identifying them and escaping correctly
        s = re.sub(r'(?<!\\)(\\\\)*"', r'\"', s)
        # Remove any extra escape characters
        s = s.replace('\\"', '"')
        # Fix any trailing commas
        s = re.sub(r',\s*]', ']', s)
        s = re.sub(r',\s*}', '}', s)
        # Ensure correct JSON structure
        s = re.sub(r'\\\\"', r'\\\"', s)
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
        return None

def convert_time_to_date(t):
    if isinstance(t, (int, float)):
        return datetime.fromtimestamp(t / 1000).strftime('%Y-%m-%d')
    return t

# Apply the function to the 'taxHistory' column using .loc to avoid SettingWithCopyWarning
prop_df.loc[:, 'taxHistory'] = prop_df['taxHistory'].apply(safe_json_loads)

# Print to check the first few rows after parsing JSON
print("After JSON parsing:")
print(prop_df.head(10))  # Limit to first 10 rows for debugging

# Remove rows where JSON parsing failed
prop_df = prop_df.dropna(subset=['taxHistory'])

# Print to check the DataFrame after dropping NaNs
print("After dropping NaNs:")
print(prop_df.head(10))  # Limit to first 10 rows for debugging

# Expand the JSON in the 'taxHistory' column
tax_history_expanded_df = prop_df.explode('taxHistory')

# Print to check the expanded DataFrame
print("After expanding JSON:")
print(tax_history_expanded_df.head(10))  # Limit to first 10 rows for debugging

# Create a DataFrame with normalized JSON data
tax_history_normalized_df = pd.json_normalize(tax_history_expanded_df['taxHistory'])

# Ensure the 'time' field is converted to a date
if 'time' in tax_history_normalized_df.columns:
    tax_history_normalized_df['time'] = tax_history_normalized_df['time'].apply(convert_time_to_date)

# Print to check the normalized DataFrame
print("After normalizing JSON:")
print(tax_history_normalized_df.head(10))  # Limit to first 10 rows for debugging

# Combine the zpid and normalized taxHistory data
result_df = tax_history_expanded_df[['zpid']].reset_index(drop=True).join(tax_history_normalized_df)

# Display the result
print("Final result:")
print(result_df.head(10))  # Limit to first 10 rows for debugging

# Save the result to a new CSV file
result_df.to_csv(output_csv_path, index=False)

print(f"Data has been saved to {output_csv_path}")
