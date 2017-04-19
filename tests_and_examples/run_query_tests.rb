# coding: utf-8

#  Tests SlicingDice endpoints.
#
#  This script tests SlicingDice by running tests suites, each composed by:
#     - Creating fields
#     - Indexing data
#     - Querying
#     - Comparing results
#
# All tests are stored in JSON files at ./examples named as the query being
# tested:
#     - count_entity.json
#     - count_event.json
#     - top_values.json
#     - aggregation.json
#
# In order to execute the tests, simply run the script with:
#     $ ruby run_tests.py

lib = File.expand_path('../../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require 'rbslicer'
require 'rbslicer/exceptions'
require 'json'

class SlicingDiceTester
  def initialize(api_key, verbose=False)
    @client = SlicingDice.new(master_key: api_key, uses_test_endpoint: true)

    # Translation table for fields with timestamp
    @field_translation = {}

    # Sleep time in seconds
    @sleep_time = 10
    # Directory containing examples to test
    @path = 'examples/'
    # Examples file format
    @extension = '.json'

    @num_successes = 0
    @num_fails = 0
    @failed_tests = []

    @verbose = verbose
  end

  attr_accessor :num_successes, :num_fails, :num_fails, :failed_tests

  # Public: Run all tests for a determined query type
  #
  # query_type(String) - the type of the query to test
  def run_tests(query_type)
    test_data = load_test_data(query_type)
    num_tests = test_data.length

    test_data.each_with_index do |test, i|
      empty_field_translation

      puts "(#{i + 1}/#{num_tests}) Executing test \"#{test['name']}\""

      if test.include? 'description'
        puts "  Description: #{test['description']}"
      end
      puts "  Query type: #{query_type}"

      begin
        create_fields test
        index_data test
        result = execute_query(query_type, test)
      rescue StandardError => e
        result = {"result" => {"error" => e.to_s}}
      end

      compare_result(test, result)
      puts
    end
  end

  # Public: Empty field translation table so tests don't intefere each other.
  def empty_field_translation
    @field_translation = {}
  end

  # Public: Load all test data from JSON file for a given query type.
  #
  # query_type(String) - String containing the name of the query that will be
  # tested. This name must match the JSON file name as well.
  #
  # Returns test data as a Hash.
  def load_test_data(query_type)
    filename = @path + query_type + @extension
    JSON.parse(File.open(filename, 'r').read)
  end

  # Public: Create fields for a given test.
  #
  # test(Hash) - Hash containing test name, fields metadata, data to be
  # indexed, query, and expected results.
  def create_fields(test)
    is_singular = test['fields'].length == 1
    field_or_fields = nil
    if is_singular
      field_or_fields = 'field'
    else
      field_or_fields = 'fields'
    end

    puts "  Creating #{test['fields'].length} #{field_or_fields}"

    test['fields'].each do |field|
      append_timestamp_to_field_name(field)
      @client.create_field(field)

      if @verbose
        puts "    - #{field['api-name']}"
      end
    end
  end

  # Public: Append integer timestamp to field name.
  #
  # This technique allows the same test suite to be executed over and over
  # again, since each execution will use different field names.
  #
  # field(Hash) - Hash containing field data, such as "name" and
  # "api-name".
  def append_timestamp_to_field_name(field)
    old_name = "\"#{field['api-name']}\""

    timestamp = get_timestamp()
    field['name'] += timestamp
    field['api-name'] += timestamp
    new_name = "\"#{field['api-name']}\""

    @field_translation[old_name] = new_name
  end

  # Public: Get integer timestamp in string format.
  #
  # Returns a string with integer timestamp.
  def get_timestamp
    # Appending integer timestamp including second decimals
    now = Time.now.to_f * 10
    return now.round.to_s
  end

  # Public: Index data for a given test on Slicing Dice API
  #
  # test(Hash) - Hash containing test name, fields metadata, data to be
  # indexed, query, and expected results.
  def index_data(test)
    is_singular = test['fields'].length == 1
    entity_or_entities = nil
    if is_singular
      entity_or_entities = 'entity'
    else
      entity_or_entities = 'entities'
    end
    puts "  Indexing #{test['fields'].length} #{entity_or_entities}"

    index_data = translate_field_names(test['index'])
    if @verbose
      puts index_data
    end

    auto_create_fields = false
    if index_data.include? 'auto-create-fields'
      auto_create_fields = index_data['auto-create-fields']
    end

    @client.index(index_data, auto_create_fields)

    # Wait a few seconds so the data can be indexed by SlicingDice
    sleep @sleep_time
  end

  # Public: Translate field name to match field name with timestamp.
  #
  # json_data - JSON data to have the field name translated.
  #
  # Returns a JSON data with new field name.
  def translate_field_names(json_data)
    data_string = JSON.dump json_data
    @field_translation.each do |old_name, new_name|
      data_string = data_string.gsub(old_name, new_name)
    end
    JSON.load data_string
  end

  # Public: Compare query expected and received results, exiting if they differ.
  #
  # test - Hash containing test name, fields metadata, data to be
  #   indexed, query, and expected results.
  # result - Hash containing received result after querying
  #   SlicingDice.
  def compare_result(test, result)
    expected = translate_field_names(test['expected'])
    expected.each do |key, value|
      if value == 'ignore'
        next
      end

      if value != result[key]
        @num_fails += 1
        @failed_tests.push(test['name'])

        puts "  Expected: \"#{key}\": #{value}"
        puts "  Result:   \"#{key}\": #{result[key]}"
        puts "  Status: Failed"
        return
      end
    end

    @num_successes += 1
    puts "  Status: Passed"
  end

  # Public: Execute query for a given test at Slicing Dice API.
  #
  # query_type - String containing the name of the query that will be
  #   tested. This name must match the JSON file name as well.
  # test - Hash containing test name, fields metadata, data to be
  #   indexed, query, and expected results.
  def execute_query(query_type, test)
    query_data = translate_field_names(test['query'])
    puts '  Querying'

    if @verbose
      puts "    - #{query_data}"
    end

    if query_type == 'count_entity'
      result = @client.count_entity(query_data)
    elsif query_type == 'count_event'
      result = @client.count_event(query_data)
    elsif query_type == 'top_values'
      result = @client.top_values(query_data)
    elsif query_type == 'aggregation'
      result = @client.aggregation(query_data)
    elsif query_type == 'result'
      result = @client.result(query_data)
    elsif query_type == 'score'
      result = @client.score(query_data)
    end

    result
  end
end


def main
  # SlicingDice queries to be tested. Must match the JSON file name.
  query_types = [
    'count_entity',
    'count_event',
    'top_values',
    'aggregation',
    'result',
    'score'
  ]

  # Testing class with demo API key
  # To get a new Demo API key visit: http://panel.slicingdice.com/docs/#api-details-api-connection-api-keys-demo-key
  sd_tester = SlicingDiceTester.new(
      api_key='eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJfX3NhbHQiOiJkZW1vOThtIiwicGVybWlzc2lvbl9sZXZlbCI6MywicHJvamVjdF9pZCI6MjU5LCJjbGllbnRfaWQiOjEwfQ.pVXws7Dcz4qLAJ1n_Pu1l4nC3NuxQVocrmBY6wU2UJw',
      verbose=false)

  begin
    query_types.each{|query_type| sd_tester.run_tests(query_type)}
  rescue Interrupt => e
  end

  puts
  puts "Results"
  puts "  Successes:#{sd_tester.num_successes}"
  puts "  Fails:#{sd_tester.num_fails}"

  sd_tester.failed_tests.each{|failed_test| puts "    - #{failed_test}"}

  puts

  if sd_tester.num_fails > 0
    is_singular = sd_tester.num_fails == 1
    test_or_tests = nil
    if is_singular
      test_or_tests = 'test has'
    else
      test_or_tests = 'tests have'
    end
    puts "FAIL: #{sd_tester.num_fails} #{test_or_tests} failed"
    exit 1
  else
    puts "SUCCESS: All tests passed"
  end
end

if __FILE__ == $0
  main
end
