#!/bin/bash

# Usage: ./migrate_and_extract.sh <source_folder> <target_folder>

# Check if the correct number of arguments are provided
if [ "$#" -ne 2 ]; then
  echo "Usage: $0 <source_folder> <target_folder>"
  exit 1
fi

SOURCE_FOLDER=$1
TARGET_FOLDER=$2
PROCESSED_DIR="$TARGET_FOLDER/processed_files"

# Create the target directory if it doesn't exist
mkdir -p "$PROCESSED_DIR"

# Find all files in the source folder and process them
find "$SOURCE_FOLDER" -type f | while read -r file; do
  echo "Processing file: $file"

  # Define the new filename with .n3 extension
  filename=$(basename "$file")
  new_file="$PROCESSED_DIR/${filename}.n3"

  # Copy the original file to the target folder with .n3 extension
  cp "$file" "$new_file"
  echo "Copied to: $new_file"

  # Extract the first line and remove the "## GRAPH " prefix, then save it to .graph file
  graph_file="$PROCESSED_DIR/${filename}.n3.graph"
  sed -n '1p' "$file" | sed 's/^## GRAPH //' > "$graph_file"
  echo "Extracted graph URI to: $graph_file"

  # Remove the first line from the copied .n3 file
  sed -i '1d' "$new_file"
  echo "Removed the first line from: $new_file"

done

echo "Migration and extraction complete."
