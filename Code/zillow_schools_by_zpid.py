<<<<<<< HEAD
# extract the school information by zpid into individual rows and produce a csv.
import pandas as pd
import json
from bs4 import BeautifulSoup
import re

# Define the paths for input and output CSV files
csv_path = r"...App/Data/zillow_property_details_combined.csv"
output_csv_path = r"...App/Data/zillow_schools_by_zpid.csv"

# Read the CSV file into a DataFrame
properties_df = pd.read_csv(csv_path, low_memory=False)

# Select columns for review
prop_df = properties_df[['zpid', 'schools']].copy()

# Define a function to aggressively clean JSON strings
def clean_json_string(s):
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

def safe_json_loads(s):
    try:
        s = clean_json_string(s)
        return json.loads(s)
    except json.JSONDecodeError as e:
        # Log the error for debugging
        print(f"JSONDecodeError: {e} for string: {s}")
        return None

# Apply the function to the 'schools' column using .loc to avoid SettingWithCopyWarning
prop_df.loc[:, 'schools'] = prop_df['schools'].apply(safe_json_loads)

# Print to check the first few rows after parsing JSON
print("After JSON parsing:")
print(prop_df.head(10))  # Limit to first 10 rows for debugging

# Remove rows where JSON parsing failed
prop_df = prop_df.dropna(subset=['schools'])

# Print to check the DataFrame after dropping NaNs
print("After dropping NaNs:")
print(prop_df.head(10))  # Limit to first 10 rows for debugging

# Expand the JSON in the 'schools' column
schools_expanded_df = prop_df.explode('schools')

# Print to check the expanded DataFrame
print("After expanding JSON:")
print(schools_expanded_df.head(10))  # Limit to first 10 rows for debugging

# Create a DataFrame with normalized JSON data
schools_normalized_df = pd.json_normalize(schools_expanded_df['schools'])

# Ensure the 'grades' field is treated as text
if 'grades' in schools_normalized_df.columns:
    schools_normalized_df['grades'] = schools_normalized_df['grades'].astype(str)

# Print to check the normalized DataFrame
print("After normalizing JSON:")
print(schools_normalized_df.head(10))  # Limit to first 10 rows for debugging

# Combine the zpid and normalized schools data
result_df = schools_expanded_df[['zpid']].reset_index(drop=True).join(schools_normalized_df)

# Display the result
print("Final result:")
print(result_df.head(10))  # Limit to first 10 rows for debugging

# Save the result to a new CSV file
result_df.to_csv(output_csv_path, index=False)

print(f"Data has been saved to {output_csv_path}")
=======
# extract the school information by zpid into individual rows and produce a csv.
import pandas as pd
import json
from bs4 import BeautifulSoup
import re

# Define the paths for input and output CSV files
csv_path = r"...App/Data/zillow_property_details_combined.csv"
output_csv_path = r"...App/Data/zillow_schools_by_zpid.csv"

# Read the CSV file into a DataFrame
properties_df = pd.read_csv(csv_path, low_memory=False)

# Select columns for review
prop_df = properties_df[['zpid', 'schools']].copy()

# Define a function to aggressively clean JSON strings
def clean_json_string(s):
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

def safe_json_loads(s):
    try:
        s = clean_json_string(s)
        return json.loads(s)
    except json.JSONDecodeError as e:
        # Log the error for debugging
        print(f"JSONDecodeError: {e} for string: {s}")
        return None

# Apply the function to the 'schools' column using .loc to avoid SettingWithCopyWarning
prop_df.loc[:, 'schools'] = prop_df['schools'].apply(safe_json_loads)

# Print to check the first few rows after parsing JSON
print("After JSON parsing:")
print(prop_df.head(10))  # Limit to first 10 rows for debugging

# Remove rows where JSON parsing failed
prop_df = prop_df.dropna(subset=['schools'])

# Print to check the DataFrame after dropping NaNs
print("After dropping NaNs:")
print(prop_df.head(10))  # Limit to first 10 rows for debugging

# Expand the JSON in the 'schools' column
schools_expanded_df = prop_df.explode('schools')

# Print to check the expanded DataFrame
print("After expanding JSON:")
print(schools_expanded_df.head(10))  # Limit to first 10 rows for debugging

# Create a DataFrame with normalized JSON data
schools_normalized_df = pd.json_normalize(schools_expanded_df['schools'])

# Ensure the 'grades' field is treated as text
if 'grades' in schools_normalized_df.columns:
    schools_normalized_df['grades'] = schools_normalized_df['grades'].astype(str)

# Print to check the normalized DataFrame
print("After normalizing JSON:")
print(schools_normalized_df.head(10))  # Limit to first 10 rows for debugging

# Combine the zpid and normalized schools data
result_df = schools_expanded_df[['zpid']].reset_index(drop=True).join(schools_normalized_df)

# Display the result
print("Final result:")
print(result_df.head(10))  # Limit to first 10 rows for debugging

# Save the result to a new CSV file
result_df.to_csv(output_csv_path, index=False)

print(f"Data has been saved to {output_csv_path}")
>>>>>>> 56df6d8 (updating all folders)
