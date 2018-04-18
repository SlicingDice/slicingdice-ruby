# coding: utf-8

# Copyright 2016 The Simbiose Ventures Developers
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
require 'rbslicer/version'
require 'rbslicer/exceptions'
require 'rbslicer/core/requester'
require 'rbslicer/core/handler_response'
require 'rbslicer/utils/validators'
require 'rbslicer/api'
require 'json'

DEFAULT_API = 'https://api.slicingdice.com/v1'.freeze
BASE_URL = ENV['SD_API_ADDRESS'].nil? ? DEFAULT_API : ENV['SD_API_ADDRESS']

# Public: A Hash with all SlicingDice methods
METHODS = {
  column: '/column/',
  insert: '/insert/',
  query_count_entity: '/query/count/entity/',
  query_count_entity_total: '/query/count/entity/total/',
  query_count_event: '/query/count/event/',
  query_aggregation: '/query/aggregation/',
  query_top_values: '/query/top_values/',
  query_exists_entity: '/query/exists/entity/',
  query_data_extraction_result: '/data_extraction/result/',
  query_data_extraction_score: '/data_extraction/score/',
  query_saved: '/query/saved/',
  database: '/database/',
  query_sql: '/sql/'
}.freeze

# Public: A ruby interface to SlicingDice API
  #
  # Examples
  #
  #    column_data = {
  #     'name' => 'Rbslicer String Column',
  #     'description' => 'Ruby Test Description',
  #     'type' => 'string',
  #     'cardinality' => 'low'
  #    }
  #    sd = SlicingDice.new('my-token')
  #    puts sd.create_column(column_data)
  #    => {
  #    ...  "status" => "SUCCESS",
  #    ...  "column_name" => "ruby-string-column"
  #    ....}
class SlicingDice < Rbslicer::SlicingDiceAPI
  def initialize(options = {})
      master_key= options.fetch(:master_key, nil)
      custom_key = options.fetch(:custom_key, nil)
      read_key = options.fetch(:read_key, nil)
      write_key = options.fetch(:write_key, nil)
      timeout = options.fetch(:timeout, 60)
      base_url= options.fetch(:base_url, BASE_URL)
    super(master_key, custom_key, read_key, write_key, timeout)
    @list_query_types = [
      "count/entity", "count/event", "count/entity/total",
      "aggregation", "top_values", "sql"]
    if base_url.nil?
      @base_url = BASE_URL
    else
      @base_url = base_url
    end
  end

  # Public: Create column in SlicingDice API
  #
  # query - A Hash in the SlicingDice column format
  #
  # Examples
  #
  #    column_data = {
  #     'name' => 'Rbslicer String Column',
  #     'description' => 'Ruby Test Description',
  #     'type' => 'string',
  #     'cardinality' => 'low'
  #    }
  #    puts sd.create_column(column_data)
  #    => {
  #    ...  "status" => "SUCCESS",
  #    ...  "column_name" => "ruby-string-column"
  #    ....}
  #
  # Returns a hash with api result
  def create_column(query)
    if query.kind_of?(Array)
      query.each { |q| column_create(q) }
    else
      column_create(query)
    end
  end

  def column_create(query)
    sd_validator = Utils::ColumnValidator.new(query)
    if sd_validator.validator
      url = @base_url + METHODS[:column]
      make_request(url, "post", 2, data= query)
    end
  end

  # Public: Get all columns created on SlicingDice API
  def get_columns()
    url = @base_url + METHODS[:column]
    make_request url, "get", 2
  end

  # Public: Send a insertion to SlicingDice API
  #
  # data - A Hash in the SlicingDice column format
  #
  # Examples
  #
  #    insert_data = {
  #      "1": {
  #        "model": "Toyota Corolla"
  #      }
  #    }
  #    puts sd.insert(insert_data)
  #    => {"status" => "SUCCESS"}
  #
  # Returns a hash with api result
  def insert(data)
    sd_validator = Utils::InsertValidator.new(data)
    if sd_validator.validator
      url = @base_url + METHODS[:insert]
      make_request(url, "post", 1, data = data)
    end
  end

  # Public: Get information about current database
  def get_database()
    url = @base_url + METHODS[:database]
    make_request url, "get", 2
  end

  # Public: Validate event and entity count query and make request
  #
  # url(String) - A url String to make request
  # query(Hash) - A Hash to send in request
  #
  # Returns a count query result in a Hash class
  def count_query_wrapper(url, query)
    sd_validator = Utils::QueryCountValidator.new(query)
    if sd_validator.validator
      make_request(url, "post", 0, data= query)
    end
  end

  # Public: Validate score and result data extraction query and make request
  #
  # url(String) - A url String to make request
  # query(Hash) - A Hash to send in request
  #
  # Returns a data extraction query result in a Hash class
  def data_extraction_wrapper(url, query)
    sd_validator = Utils::QueryDataExtractionValidator.new(query)
    if sd_validator.validator
      make_request(url, "post", 0, data= query)
    end
  end

  # Public: Make a request to SlicingDice API to save or update a saved query
  #
  # url(String) - A url String to make request
  # query(Hash) - A Hash to send in request
  # update(Boolean) - Indicate if the query is to update (true) or to create (false)
  def saved_query_wrapper(url, query, update = false)
    if update
      make_request(url, "put", 2, data= query)
    else
      make_request(url, "post", 2, data=query)
    end
  end

  # Public: Make a count entity query in SlicingDice API
  #
  # query(Hash) - A Hash to send in request
  #
  # Returns a count entity query result
  def count_entity(query)
    url = @base_url + METHODS[:query_count_entity]
    count_query_wrapper(url, query)
  end

  # Public: Make a total query in SlicingDice API
  #
  # dimensions(Hash) - A Hash to send in request containing the dimensions in which
  #                the total query will be performed
  #
  # Returns a count entity total query result
  def count_entity_total(dimensions=[])
    url = @base_url + METHODS[:query_count_entity_total]

    query = {
      "dimensions" => dimensions
    }

    make_request(url, "post", 0, data=query)
  end

  # Public: Make a count event query in SlicingDice API
  #
  # query(Hash) - A Hash to send in request
  #
  # Returns a count event query result
  def count_event(query)
    url = @base_url + METHODS[:query_count_event]
    count_query_wrapper(url, query)
  end

  # Public: Make a aggregation query in SlicingDice API
  #
  # query(Hash) - A Hash to send in request
  #
  # Returns a aggregation query result
  def aggregation(query)
    url = @base_url + METHODS[:query_aggregation]
    if !query.key?("query")
      raise Exceptions::InvalidQueryException, 'The aggregation query must '\
                                               'have \'query\' property.'
    end
    columns = query["query"]
    if columns.length > 5
      raise Exceptions::MaxLimitExceptions, 'The aggregation query must have'\
                                            ' up to 5 columns per request.'
    end
    make_request(url, "post", 0, data=query)
  end

  # Public: Make a top values query in SlicingDice API
  #
  # query(Hash) - A Hash to send in request
  #
  # Returns a top values query result
  def top_values(query)
    url = @base_url + METHODS[:query_top_values]
    sd_validator = Utils::QueryTopValuesValidator.new(query)
    if sd_validator.validator
      make_request(url, "post", 0, data=query)
    end
  end

  # Public: Check if a list of entities exists in SlicingDice API
  #
  # ids(Array) - A Array with ids to be checked
  # dimension(String) - In which dimension entities check be checked
  #
  # Returns a Hash with ids that exists and that don't exits
  def exists_entity(ids, dimension=nil)
    url = @base_url + METHODS[:query_exists_entity]
    if ids.length > 100
      raise Exceptions::MaxLimitExceptions, 'The query exists entity must '\
                                            'have up to 100 ids.'
    end
    query = {
      'ids' => ids
    }
    if dimension.nil?
      query['dimension'] = dimension
    end
    make_request(url, "post", 0, data=query)
  end

  # Public: Get all saved queries
  #
  # query_name(String) - Name of saved query to recover in SlicingDice API
  #
  # Returns a hash with saved query
  def get_saved_queries()
    url = @base_url + METHODS[:query_saved]
    make_request url, "get", 2
  end

  # Public: Get a specific saved query
  #
  # query_name(String) - Name of saved query to recover in SlicingDice API
  #
  # Returns a hash with saved query
  def get_saved_query(query_name)
    url = @base_url + METHODS[:query_saved] + query_name
    make_request url, "get", 0
  end

  # Public: Delete a specific saved query
  #
  # query_name(String) - Name of saved query to recover in SlicingDice API
  #
  # Returns a hash with saved query
  def delete_saved_query(query_name)
    url = @base_url + METHODS[:query_saved] + query_name
    make_request url, "delete", 2
  end

  # Public: Create a saved query in SlicingDice API
  #
  # query(Hash) - A Hash to send in request
  #
  # Returns a hash with saved query created and SUCCESS status
  def create_saved_query(query)
    url = @base_url + METHODS[:query_saved]
    saved_query_wrapper url, query
  end

  # Public: Update a saved query in SlicingDice API
  #
  # name(String) - Name of saved query to update in SlicingDice API
  # query(Hash) - A Hash to send in request
  #
  # Returns a hash with saved query updated and SUCCESS status
  def update_saved_query(name, query)
    url = @base_url + METHODS[:query_saved] + name
    saved_query_wrapper(url, query, update=true)
  end

  # Public: Get a data extraction result query
  #
  # query(Hash) - A Hash to send in request
  def result(query)
    url = @base_url + METHODS[:query_data_extraction_result]
    data_extraction_wrapper(url, query)
  end

  # Public: Get a data extraction score query
  #
  # query(Hash) - A Hash to send in request
  def score(query)
    url = @base_url + METHODS[:query_data_extraction_score]
    data_extraction_wrapper(url, query)
  end

  def sql(query)
    url = @base_url + METHODS[:query_sql]
    make_request(url, "post", 0, data=query, sql=true)
  end
end
