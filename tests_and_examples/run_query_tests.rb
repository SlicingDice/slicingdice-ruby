# coding: utf-8

#  Tests SlicingDice endpoints.
#
#  This script tests SlicingDice by running tests suites, each composed by:
#     - Creating columns
#     - Inserting data
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

    # Translation table for columns with timestamp
    @column_translation = {}

    # Sleep time in seconds
    @sleep_time = 5
    # Directory containing examples to test
    @path = 'examples/'
    # Examples file format
    @extension = '.json'

    @num_successes = 0
    @num_fails = 0
    @failed_tests = []

    @verbose = verbose

    @per_test_insert = false
  end

  attr_accessor :num_successes, :num_fails, :num_fails, :failed_tests

  # Public: Run all tests for a determined query type
  #
  # query_type(String) - the type of the query to test
  def run_tests(query_type)
    test_data = load_test_data(query_type)
    num_tests = test_data.length

    @per_test_insert = test_data[0].key?("insert")
    
    if !@per_test_insert
      insertion_data = load_test_data(query_type, suffix="_insert")
      insertion_data.each do |insert_command|
        @client.insert(insert_command)
      end

      sleep @sleep_time
    end

    test_data.each_with_index do |test, i|
      empty_column_translation

      puts "(#{i + 1}/#{num_tests}) Executing test \"#{test['name']}\""

      if test.include? 'description'
        puts "  Description: #{test['description']}"
      end
      puts "  Query type: #{query_type}"

      begin
        if @per_test_insert
          create_columns test
          insert_data test
        end
        result = execute_query(query_type, test)
      rescue StandardError => e
        result = {"result" => {"error" => e.to_s}}
      end

      compare_result(test, result)
      puts
    end
  end

  # Public: Empty column translation table so tests don't intefere each other.
  def empty_column_translation
    @column_translation = {}
  end

  # Public: Load all test data from JSON file for a given query type.
  #
  # query_type(String) - String containing the name of the query that will be
  # tested. This name must match the JSON file name as well.
  #
  # Returns test data as a Hash.
  def load_test_data(query_type, suffix = "")
    filename = @path + query_type + suffix + @extension
    JSON.parse(File.open(filename, 'r').read)
  end

  # Public: Create columns for a given test.
  #
  # test(Hash) - Hash containing test name, columns metadata, data to be
  # inserted, query, and expected results.
  def create_columns(test)
    is_singular = test['columns'].length == 1
    column_or_columns = nil
    if is_singular
      column_or_columns = 'column'
    else
      column_or_columns = 'columns'
    end

    puts "  Creating #{test['columns'].length} #{column_or_columns}"

    test['columns'].each do |column|
      append_timestamp_to_column_name(column)
      @client.create_column(column)

      if @verbose
        puts "    - #{column['api-name']}"
      end
    end
  end

  # Public: Append integer timestamp to column name.
  #
  # This technique allows the same test suite to be executed over and over
  # again, since each execution will use different column names.
  #
  # column(Hash) - Hash containing column data, such as "name" and
  # "api-name".
  def append_timestamp_to_column_name(column)
    old_name = "\"#{column['api-name']}\""

    timestamp = get_timestamp()
    column['name'] += timestamp
    column['api-name'] += timestamp
    new_name = "\"#{column['api-name']}\""

    @column_translation[old_name] = new_name
  end

  # Public: Get integer timestamp in string format.
  #
  # Returns a string with integer timestamp.
  def get_timestamp
    # Appending integer timestamp including second decimals
    now = Time.now.to_f * 10
    return now.round.to_s
  end

  # Public: Insert data for a given test on Slicing Dice API
  #
  # test(Hash) - Hash containing test name, columns metadata, data to be
  # inserted, query, and expected results.
  def insert_data(test)
    is_singular = test['insert'].length == 1
    entity_or_entities = nil
    if is_singular
      entity_or_entities = 'entity'
    else
      entity_or_entities = 'entities'
    end
    puts "  Inserting #{test['insert'].length} #{entity_or_entities}"

    insert_data = translate_column_names(test['insert'])
    if @verbose
      puts insert_data
    end

    @client.insert(insert_data)

    # Wait a few seconds so the data can be inserted by SlicingDice
    sleep @sleep_time
  end

  # Public: Translate column name to match column name with timestamp.
  #
  # json_data - JSON data to have the column name translated.
  #
  # Returns a JSON data with new column name.
  def translate_column_names(json_data)
    data_string = JSON.dump json_data
    @column_translation.each do |old_name, new_name|
      data_string = data_string.gsub(old_name, new_name)
    end
    JSON.load data_string
  end

  # Public: Compare query expected and received results, exiting if they differ.
  #
  # test - Hash containing test name, columns metadata, data to be
  #   inserted, query, and expected results.
  # result - Hash containing received result after querying
  #   SlicingDice.
  def compare_result(test, result)
    if @per_test_insert
      expected = translate_column_names(test['expected'])
    else
      expected = test['expected']
    end
    expected.each do |key, value|
      if value == 'ignore'
        next
      end

      if !compare_values(value, result[key])
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

  def compare_values(expected, got)
    if expected.is_a?(Hash)
      if !got.is_a?(Hash)
        return false
      end

      if expected.length != got.length
        return false
      end

      expected.each do |key, value|
        got_value = got[key]
        if !compare_values(value, got_value)
          return false
        end
      end

      return true
    elsif expected.is_a?(Array)
      if !got.is_a?(Array)
        return false
      end

      if expected.length != got.length
        return false
      end

      expected.each do |value|
        has_value = false
        got.each do |value_got|
          if compare_values(value, value_got)
            has_value = true
          end
        end
        if !has_value
          return false
        end
      end

      return true
    end

    return expected == got
  end

  # Public: Execute query for a given test at Slicing Dice API.
  #
  # query_type - String containing the name of the query that will be
  #   tested. This name must match the JSON file name as well.
  # test - Hash containing test name, columns metadata, data to be
  #   inserted, query, and expected results.
  def execute_query(query_type, test)
    if @per_test_insert
      query_data = translate_column_names(test['query'])
    else
      query_data = test['query']
    end
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
    elsif query_type == 'sql'
      result = @client.sql(query_data)
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
    'score',
    'sql'
  ]

  # Testing class with demo API key
  # To get a new Demo API key visit: http://panel.slicingdice.com/docs/#api-details-api-connection-api-keys-demo-key
  sd_tester = SlicingDiceTester.new(
    api_key='eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJfX3NhbHQiOiJkZW1vNzY0bSIsInBlcm1pc3Npb25fbGV2ZWwiOjMsInByb2plY3RfaWQiOjIwNzY0LCJjbGllbnRfaWQiOjEwfQ.LdACS48Ps0hrJ87KD5PAEfpEU4k_abbdhzaFF_EyEus',
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
