# water, 0V, intensity 0.5, 
# IMPORTANT: min r2 0.4

import re

data = """
    {[16:29:11.024000]}    {'Error: poor fit'}
    {[16:29:15.086000]}    {'Error: poor fit'}
    {[16:29:19.148000]}    {'Error: poor fit'}
    {[16:29:23.229000]}    {'Error: poor fit'}
    {[16:29:27.281000]}    {'Error: poor fit'}
    {[16:29:31.316000]}    {'Error: poor fit'}
    {[16:29:35.361000]}    {'Error: poor fit'}
    {[16:29:39.401000]}    {'Error: poor fit'}
    {[16:29:43.450000]}    {'Error: poor fit'}"""

# Define a regex pattern that captures the second element (inside the second curly braces)
pattern = re.compile(r'\{[^\}]*\}\s*\{([^\}]*)\}')

# Create an empty list to store the extracted elements
values = []

# Process each line in the data
for line in data.splitlines():
    match = pattern.search(line)
    if match:
        # Extract and strip any extra whitespace from the captured group
        value = match.group(1).strip().strip('\'"')
        if value.startswith('[') and value.endswith(']'):
            value = value[1:-1].strip()
        values.append(value)
