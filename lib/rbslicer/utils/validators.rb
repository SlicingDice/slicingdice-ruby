# coding: utf-8

require 'rbslicer/utils/data_utils'
require 'rbslicer/exceptions'

module Utils
  # Public: Validates insert data to send API
  class InsertValidator
    # Public: Initialize InsertValidator object
    #
    # hash_data - A Hash data to analyze
    def initialize(hash_data)
      @hash_data = hash_data
    end

    # Public: Check if insert have empty/invalid columns
    #
    # Returns false if don't have empty/invalid columns
    def empty_column?
      to_values = @hash_data.any? { |v| v.nil? }
      to_keys = @hash_data.values.any? { |v| v.nil? }
      if to_values || to_keys
        raise Exceptions::InvalidInsertException, 'This insert has invalid keys '\
                                                  'or values.'
      end
      false
    end

    # Public: Validates insert data.
    #
    # Returns true if insert data is valid
    def validator
      true unless empty_column?
    end

    private :empty_column?
  end

  # Public: Validates column to send API
  class ColumnValidator
    # Public: Initialize InsertValidator object
    #
    # hash_data - A Hash data to analyze
    def initialize(hash_data)
      @hash_data = hash_data
      @valid_type_columns =
        ["unique-id", "boolean", "string", "integer", "decimal",
          "enumerated", "date", "integer-event",
          "decimal-event", "string-event", "datetime"]
    end

    # Public: Validates key 'name' in column
    #
    # Returns true if key 'name' is valid for Slicing Dice
    def validate_name
      if @hash_data.key?('name')
        name = @hash_data['name']
        if Utils::DataUtils.string_empty name
          raise Exceptions::InvalidColumnNameException, 'The column\'s name '\
                                                        'can\'t be empty/None.'
        elsif name.length > 80
          raise Exceptions::InvalidColumnNameException, 'The column\'s name '\
                                          'have a very big content. (Max: 80 chars)'
        end
      else
        raise Exceptions::InvalidColumnException, 'The column should have a name.'
      end
      true
    end

    # Public: Validates key 'description' in column
    #
    # Returns true if description is valid for Slicing Dice
    def validate_description
      description = @hash_data['description']
      if Utils::DataUtils.string_empty description
        raise Exceptions::InvalidColumnDescriptionException, 'The column\'s '\
                                            'description can\'t be empty/None.'
      elsif description.length > 300
        raise Exceptions::InvalidColumnDescriptionException, 'The column\'s '\
                            'description have a very big content. (Max: 300 chars)'
      end
      true
    end


    # Public: Validates key 'type' in column
    #
    # Returns true if key 'type' is valid for Slicing Dice
    def validate_column_type
      unless @hash_data.key?('type')
        raise Exceptions::InvalidColumnException, 'The column should have a type.'
      end
      type_column = @hash_data['type']
      unless @valid_type_columns.include? type_column
        raise Exceptions::InvalidColumnTypeException, 'This column have a '\
                                                      'invalid type.'
      end
      if type_column == 'integer' && @hash_data.key?('cardinality')
        raise Exceptions::InvalidColumnException, 'Invalid column.'
      end
    end

    # Public: Check if column has key 'cardinality'
    # This method is used to check if String type column is valid
    def check_str_type_integrity
      unless @hash_data.key?('cardinality')
        raise Exceptions::InvalidColumnException, 'The column with type string '\
                                      'should have \'cardinality\' key.'
      end
      cardinality_types = ["high", "low"]
      unless cardinality_types.include? @hash_data['cardinality']
        raise Exceptions::InvalidColumnException, 'The column \'cardinality\' '\
                                                  'has invalid value.'
      end
    end

    # Public: Check if column has a valid decimal types
    def validate_column_decimal_places
      decimal_types = ["decimal", "decimal-event"]
      unless decimal_types.include? @hash_data['type']
        raise Exceptions::InvalidColumnException,  'This column is only accepted'\
                                                  ' on type \'decimal\' or'
                                                  ' decimal-event'
      end
    end

    # Public: Check if enumerated column is valid
    def validate_enumerated_type
      unless @hash_data.key? 'range'
        raise Exceptions::InvalidColumnException, 'The \'enumerate\' type needs'\
                                                  ' \'range\' parameter.'
      end
    end

    # Public: Validates column data
    #
    # Returns true if column data has all requirements
    def validator
      validate_name
      validate_column_type
      validate_column_decimal_places if @hash_data.key? 'decimal-place'
      validate_enumerated_type if @hash_data.key? 'enumerated'
      check_str_type_integrity if @hash_data['type'] == 'string'
      validate_description if @hash_data.key? 'description'
      true
    end
  end

  class QueryCountValidator
    def initialize(queries)
      @queries = queries
    end

    # Public: Validates count queries
    #
    # Returns true if count query is valid
    def validator
      if @queries.length > 10
        raise Exceptions::MaxLimitException, 'The query count entity has a '\
                                              'limit of 10 queries per request.'
      end
      true
    end
  end

  class QueryDataExtractionValidator
    def initialize(queries)
      @queries = queries
    end

    # Public: Validates query data extraction queries (score or result)
    #
    # Returns true if data extraction query is valid
    def valid_keys?
      @queries.each do |key, value|
        if key == "limit"
          if !value.is_a?(Integer)
            raise Exceptions::InvalidQueryException, 'The key \'limit\' in '\
                                                    'query has a invalid value.'
          end
        elsif key == "columns"
          if !value.is_a?(Array)
            if value != "all"
              raise Exceptions::InvalidQueryException, 'The key \'columns\' in '\
                                                      'query has a invalid value.'
            end
          else
            if value.length > 10
              raise Exceptions::MaxLimitException, 'The key \'columns\' in '\
                            'data extraction result must have up to 10 columns.'
            end
          end
        elsif key == "query"
          true
        elsif key == "order"
          if !value.is_a?(Array)
            raise Exceptions::InvalidQueryException, 'The key \'order\' in '\
                                                    'query has a invalid value.'
          elsif value.empty?
            raise Exceptions::InvalidQueryException, 'The key \'order\' in '\
                                                    'query has a empty array.'
          end
        else
          raise Exceptions::InvalidQueryException, "This query have the invalid"\
                                                  " key #{key}"
        end
      end
      true
    end

    def validator
      true if valid_keys?
    end
  end

  class QueryTopValuesValidator
    def initialize(queries)
      @queries = queries
    end

    # Public: Verify if top values query exceeds query limit
    #
    # Returns true if exceeds, false otherwise
    def exceeds_queries_limit
      true if @queries.length > 5
    end

    # Public: Verify if top values query exceeds columns limit
    #
    # Returns false if not exceeds
    def exceeds_columns_limit
      @queries.each do |key, value|
        if value.length > 6
          raise Exceptions::MaxLimitException, "The query #{key} exceeds the "\
                                                "limit of columns per query "\
                                                "in request"
        end
      end
      false
    end

    # Public: Verify if top values query exceeds contains limit
    #
    # Returns false if not exceeds
    def exceeds_values_contains_limit
      @queries.each do |key, value|
        if value.key? 'contains'
          if value['contains'].length > 5
            raise Exceptions::MaxLimitException, "The query #{key} exceeds the "\
                                                  "limit of contains per "\
                                                  "query in request"
          end
        end
      end
      false
    end

    # Public: Validates top values queries
    #
    # Returns true if top values query is valid
    def validator
      true if !exceeds_queries_limit &&
              !exceeds_columns_limit &&
              !exceeds_values_contains_limit
    end
  end
end
