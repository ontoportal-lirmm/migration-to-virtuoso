require 'active_support'
require 'active_support/core_ext'
require 'ontologies_linked_data'

def generate_rdf(logger, submission:, reasoning: true)
  LinkedData::Services::SubmissionRDFGenerator.new(submission).process(logger, reasoning: reasoning)
end

LinkedData.config do |config|
  Goo.log_file = "./sparql.log"
  config.goo_host = "localhost"
  config.goo_backend_name    = '4store'
  config.goo_port            = 9000
  config.goo_host            = 'localhost'
  config.goo_path_query      = '/sparql/'
  config.goo_path_data       = '/data/'
  config.goo_path_update     = '/update/'

  # config.goo_backend_name = "virtuoso"
  # config.goo_port = "8890"
  # config.goo_path_query = "/sparql"
  # config.goo_path_data = "/sparql"
  # config.goo_path_update = "/sparql"
  config.repository_folder = './test_files'
end
file_path = '/home/syphax/Work/ontoportal_projects/migration-to-virtuoso/test_files/agrovoc_2023-11-03_lod.ttl'

_, _, onts = LinkedData::SampleData::Ontology.create_ontologies_and_submissions(ont_count: 1,
                                                                                submission_count: 1)
logger = Logger.new(STDOUT)
sub = onts.first.latest_submission(status: :any)
sub.bring_remaining

Goo.sparql_data_client.delete_graph('http://data.bioontology.org/ontologies/TEST-ONT-0/submissions/1')
time = Benchmark.measure do
  Goo.sparql_data_client.append_triples_no_bnodes(sub.id, file_path, nil)
end
puts 'Time to append triples: ' + time.real.to_s


page = 1
pagesize = 10000
count = 1
total_count = 0
time = Benchmark.measure do
  while count > 0 && page < 100
    puts "Starting query for page #{page}"
    offset = " OFFSET #{(page - 1) * pagesize}" if page > 1
    rs = Goo.sparql_query_client.query("SELECT ?s ?p ?o FROM <http://data.bioontology.org/ontologies/TEST-ONT-0/submissions/1> WHERE {  ?s ?p ?o  } LIMIT #{pagesize} #{offset}")
    count = rs.each_solution.size
    total_count += count
    page += 1
  end
end
puts 'Time to query triples: ' + time.real.to_s + ' with total count: ' + total_count.to_s


# generate_rdf(logger, submission: sub, reasoning: true)
