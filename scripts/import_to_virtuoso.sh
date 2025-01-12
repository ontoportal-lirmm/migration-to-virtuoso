#!/bin/bash

# Stop the script at the first error
set -e

# Check if the correct number of arguments are provided
if [ "$#" -ne 3#!/bin/bash

# Stop the script at the first error
set -e

# Check if the correct number of arguments are provided
if [ "$#" -ne 4 ]; then
  echo "Usage: $0 <virtuoso_username> <virtuoso_password> <processed_directory>"
  exit 1
fi

# Virtuoso credentials
VIRTUOSO_USER=$1
VIRTUOSO_PASS=$2

# Directory containing .n3 files (from the provided argument)
PROCESSED_DIR=$3

VIRTUOSO_DIR=$4

# Virtuoso ISQL command to import files
ISQL_CMD="isql 1111 $VIRTUOSO_USER $VIRTUOSO_PASS"

# Check if processed_files directory exists
if [ ! -d "$PROCESSED_DIR" ]; then
  echo "Processed files directory $PROCESSED_DIR does not exist!"
  exit 1
fi

# Loop through all .n3 files in the processed_files directory
for file in "$PROCESSED_DIR"/*.n3; do
  # Extract the associated .graph file (contains graph URI)
  graph_file="${file%.n3}.n3.graph"

  # Check if graph file exists
  if [ ! -f "$graph_file" ]; then
    echo "Graph file $graph_file not found. Skipping import of $file."
    continue
  fi

  # Extract the graph URI from the graph file
  graph_uri=$(cat "$graph_file")
#
#  # Clean the graph first
#  echo "Cleaning graph <$graph_uri> in Virtuoso..."
#  docker exec -i $(docker ps -q -f "name=virtuoso") isql-v 1111 "$VIRTUOSO_USER" "$VIRTUOSO_PASS" \
#                   exec="SPARQL DROP SILENT GRAPH <$graph_uri>"

  # Check if the cleaning was successful
  if [ $? -ne 0 ]; then
    echo "Failed to clean graph <$graph_uri>. Skipping import of $file."
    continue
  fi

  # Print status of the cleaning operation
  echo "Successfully cleaned graph <$graph_uri>."

  # Run Virtuoso ISQL command to load the data into the specified graph
  if ! "$VIRTUOSO_DIR"/bin/isql 1111 "$VIRTUOSO_USER" "$VIRTUOSO_PASS" exec="ld_dir('./$PROCESSED_DIR', '$(basename "$file")', '$graph_uri')"; then
    echo "Error importing $file into graph <$graph_uri>. Exiting script."
    exit 1
  fi

  # Execute the load command in Virtuoso
  echo "Executing the load process in Virtuoso..."
  "$VIRTUOSO_DIR"/bin/isql 1111 "$VIRTUOSO_USER" "$VIRTUOSO_PASS" exec="rdf_loader_run()"
  echo "Load process completed."

  # Print the completion of the import for the current file
  echo "Imported $file into graph <$graph_uri>"
  echo "--------------------------------"
done
 ]; then
  echo "Usage: $0 <virtuoso_username> <virtuoso_password> <processed_directory>"
  exit 1
fi

# Virtuoso credentials
VIRTUOSO_USER=$1
VIRTUOSO_PASS=$2

# Directory containing .n3 files (from the provided argument)
PROCESSED_DIR=$3

VIRTUOSO_DIR=$4

# Virtuoso ISQL command to import files
ISQL_CMD="isql 1111 $VIRTUOSO_USER $VIRTUOSO_PASS"

# Check if processed_files directory exists
if [ ! -d "$PROCESSED_DIR" ]; then
  echo "Processed files directory $PROCESSED_DIR does not exist!"
  exit 1
fi

# Loop through all .n3 files in the processed_files directory
for file in "$PROCESSED_DIR"/*.n3; do
  # Extract the associated .graph file (contains graph URI)
  graph_file="${file%.n3}.n3.graph"

  # Check if graph file exists
  if [ ! -f "$graph_file" ]; then
    echo "Graph file $graph_file not found. Skipping import of $file."
    continue
  fi

  # Extract the graph URI from the graph file
  graph_uri=$(cat "$graph_file")
#
#  # Clean the graph first
#  echo "Cleaning graph <$graph_uri> in Virtuoso..."
#  docker exec -i $(docker ps -q -f "name=virtuoso") isql-v 1111 "$VIRTUOSO_USER" "$VIRTUOSO_PASS" \
#                   exec="SPARQL DROP SILENT GRAPH <$graph_uri>"

  # Check if the cleaning was successful
  if [ $? -ne 0 ]; then
    echo "Failed to clean graph <$graph_uri>. Skipping import of $file."
    continue
  fi

  # Print status of the cleaning operation
  echo "Successfully cleaned graph <$graph_uri>."

  # Run Virtuoso ISQL command to load the data into the specified graph
  if ! "$VIRTUOSO_DIR"/bin/isql 1111 "$VIRTUOSO_USER" "$VIRTUOSO_PASS" exec="ld_dir('./$PROCESSED_DIR', '$(basename "$file")', '$graph_uri')"; then
    echo "Error importing $file into graph <$graph_uri>. Exiting script."
    exit 1
  fi

  # Execute the load command in Virtuoso
  echo "Executing the load process in Virtuoso..."
  "$VIRTUOSO_DIR"/bin/isql 1111 "$VIRTUOSO_USER" "$VIRTUOSO_PASS" exec="rdf_loader_run()"
  echo "Load process completed."

  # Print the completion of the import for the current file
  echo "Imported $file into graph <$graph_uri>"
  echo "--------------------------------"
done
