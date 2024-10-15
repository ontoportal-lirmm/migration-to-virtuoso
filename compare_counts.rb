
require 'open3'
require 'net/http'
require 'json'
require 'cgi'
require 'csv'
require 'pry'
# Set your Virtuoso SPARQL endpoint, user credentials, and the directory where the .n3 files are located
VIRTUOSO_SPARQL_ENDPOINT = 'http://localhost:8890/sparql'
VIRTUOSO_USER = 'dba'
VIRTUOSO_PASS = 'dba'
PROCESSED_DIR = './processed_files'
OUTPUT_CSV = './graph_comparison.csv'

# Query Virtuoso for graph triple counts
def get_graph_triple_counts
  query = <<-SPARQL
    SELECT ?graph (COUNT(?s) AS ?triplesCount)
    WHERE {
      GRAPH ?graph {
        ?s ?p ?o .
      }
    }
    GROUP BY ?graph
    ORDER BY DESC(?triplesCount)
  SPARQL

  encoded_query = CGI.escape(query)  # Use CGI.escape for URL encoding

  uri = URI("#{VIRTUOSO_SPARQL_ENDPOINT}?query=#{encoded_query}&format=#{CGI.escape('application/sparql-results+json')}")

  # Perform the SPARQL query and get the result
  req = Net::HTTP::Get.new(uri)
  req.basic_auth(VIRTUOSO_USER, VIRTUOSO_PASS)

  res = Net::HTTP.start(uri.hostname, uri.port) { |http| http.request(req) }

  if res.is_a?(Net::HTTPSuccess)
    JSON.parse(res.body)["results"]["bindings"]
  else
    puts "Failed to query Virtuoso: #{res.body}"
    exit 1
  end
end

# Count the number of lines in a file (excluding the first metadata line)
def count_file_lines(file_path)
  File.read(file_path).each_line.count
end

def build_graphs_file_hash(folder_path = PROCESSED_DIR)
  # Ensure the folder path exists
  unless Dir.exist?(folder_path)
    puts "Folder does not exist: #{folder_path}"
    return
  end

  graphs = {}
  # Loop through each file in the folder
  Dir.foreach(folder_path) do |filename|
    # Skip directories and only process files ending with .graph and starting with the specific string
    if filename.end_with?('.graph')
      file_path = File.join(folder_path, filename)
      line = File.open(file_path, "r").readlines.first
      graphs[line.strip] = filename.to_s.gsub('.graph','')
    end
  end
  graphs
end

# Compare graph counts with file lines and output to CSV
def compare_graphs_with_files(graph_triples)
  CSV.open(OUTPUT_CSV, 'w') do |csv|
    # Write CSV headers
    csv << ["Graph URI", "Triples in Graph", "Lines in File (excluding metadata)", "Match"]
    graphs_files = build_graphs_file_hash
    graph_triples.each do |graph|
      graph_uri = graph['graph']['value']
      triples_count = graph['triplesCount']['value'].to_i

      graph_filename = graphs_files[graph_uri]
      next unless graph_filename
      
      # Construct the expected file name based on the graph URI
      file_name = "#{PROCESSED_DIR}/#{graph_filename}"
      
      puts "count lines of the file #{file_name} for the graph #{graph_uri}"
      if File.exist?(file_name)
        file_lines_count = count_file_lines(file_name)

        # Check if the counts match
        match_status = triples_count == file_lines_count ? "Yes" : "No"

        # Output the result to CSV
        csv << [graph_uri, triples_count, file_lines_count, match_status]
      else
        # If the file doesn't exist, indicate it in the CSV
        csv << [graph_uri, triples_count, "File not found", "N/A"]
      end
    end
  end

  puts "Comparison complete. Results saved to #{OUTPUT_CSV}"
end

# Main execution
puts "Comparing graph triple counts with file lines and exporting to CSV..."
graph_triples = get_graph_triple_counts
compare_graphs_with_files(graph_triples)
