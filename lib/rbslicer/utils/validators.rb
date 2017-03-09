# coding: utf-8

require 'rbslicer/utils/data_utils'
require 'rbslicer/exceptions'

module Utils
  # Public: Validates index data to send API
  class IndexValidator
    # Public: Initialize IndexValidator object
    #
    # hash_data - A Hash data to analyze
    def initialize(hash_data)
      @hash_data = hash_data
    end

    # Public: Check if index have empty/invalid fields
    #
    # Returns false if don't have empty/invalid fields
    def empty_field?
      to_values = @hash_data.any? { |v| v.nil? }
      to_keys = @hash_data.values.any? { |v| v.nil? }
      if to_values || to_keys
        raise Exceptions::InvalidIndexException, 'This index has invalid keys '\
                                                  'or values.'
      end
      false
    end

    # Public: Validates index data.
    #
    # Returns true if index data is valid
    def validator
      true unless empty_field?
    end

    private :empty_field?
  end

  # Public: Validates field to send API
  class FieldValidator
    # Public: Initialize IndexValidator object
    #
    # hash_data - A Hash data to analyze
    def initialize(hash_data)
      @hash_data = hash_data
      @valid_type_fields = 
        ["unique-id", "boolean", "string", "integer", "decimal",
          "enumerated", "date", "integer-time-series",
          "decimal-time-series", "string-time-series"]
    end

    # Public: Validates key 'name' in field
    #
    # Returns true if key 'name' is valid for Slicing Dice
    def validate_name
      if @hash_data.key?('name')
        name = @hash_data['name']
        if Utils::DataUtils.string_empty name
          raise Exceptions::InvalidFieldNameException, 'The field\'s name '\
                                                        'can\'t be empty/None.'
        elsif name.length > 80
          raise Exceptions::InvalidFieldNameException, 'The field\'s name '\
                                          'have a very big content. (Max: 80 chars)'
        end
      else
        raise Exceptions::InvalidFieldException, 'The field should have a name.'
      end
      true
    end

    # Public: Validates key 'description' in field
    #
    # Returns true if description is valid for Slicing Dice
    def validate_description
      description = @hash_data['description']
      if Utils::DataUtils.string_empty description
        raise Exceptions::InvalidFieldDescriptionException, 'The field\'s '\
                                            'description can\'t be empty/None.'
      elsif description.length > 300
        raise Exceptions::InvalidFieldDescriptionException, 'The field\'s '\
                            'description have a very big content. (Max: 300 chars)'
      end
      true
    end


    # Public: Validates key 'type' in field
    #
    # Returns true if key 'type' is valid for Slicing Dice
    def validate_field_type
      unless @hash_data.key?('type')
        raise Exceptions::InvalidFieldException, 'The field should have a type.'
      end
      type_field = @hash_data['type']
      unless @valid_type_fields.include? type_field
        raise Exceptions::InvalidFieldTypeException, 'This field have a '\
                                                      'invalid type.'
      end
      if type_field == 'integer' && @hash_data.key?('cardinality')
        raise Exceptions::InvalidFieldException, 'Invalid field.'
      end
    end

    # Public: Check if field has key 'cardinality'
    # This method is used to check if String type field is valid
    def check_str_type_integrity
      unless @hash_data.key?('cardinality')
        raise Exceptions::InvalidFieldException, 'The field with type string '\
                                      'should have \'cardinality\' key.'
      end
      cardinality_types = ["high", "low"]
      unless cardinality_types.include? @hash_data['cardinality']
        raise Exceptions::InvalidFieldException, 'The field \'cardinality\' '\
                                                  'has invalid value.'
      end
    end

    # Public: Check if field has a valid decimal types
    def validate_field_decimal_places
      decimal_types = ["decimal", "decimal-time-series"]
      unless decimal_types.include? @hash_data['type']
        raise Exceptions::InvalidFieldException,  'This field is only accepted'\
                                                  ' on type \'decimal\' or'
                                                  ' decimal-time-series'
      end
    end

    # Public: Check if enumerated field is valid
    def validate_enumerated_type
      unless @hash_data.key? 'range'
        raise Exceptions::InvalidFieldException, 'The \'enumerate\' type needs'\
                                                  ' \'range\' parameter.'
      end
    end

    # Public: Validates field data
    #
    # Returns true if field data has all requirements
    def validator
      validate_name
      validate_field_type
      validate_field_decimal_places if @hash_data.key? 'decimal-place'
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
          elsif value > 100
            raise Exceptions::InvalidQueryException, 'The field \'limit\' has '
                                                      'a value max of 100.'
          end
        elsif key == "fields"
          if !value.is_a?(Array)
            raise Exceptions::InvalidQueryException, 'The key \'fields\' in '\
                                                    'query has a invalid value.'
          else
            if value.length > 10
              raise Exceptions::MaxLimitException, 'The key \'fields\' in '\
                            'data extraction result must have up to 10 fields.'
            end
          end
        elsif key == "query"
          true
        else
          raise Exceptions::InvalidQueryException, "This query have the invalid"\
                                                  "key #{key}"
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

    # Public: Verify if top values query exceeds fields limit
    #
    # Returns false if not exceeds
    def exceeds_fields_limit
      @queries.each do |key, value|
        if value.length > 6
          raise Exceptions::MaxLimitException, "The query #{key} exceeds the "\
                                                "limit of fields per query "\
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
              !exceeds_fields_limit && 
              !exceeds_values_contains_limit
    end
  end
end
