# coding: utf-8

require 'rbslicer/exceptions'
require 'rbslicer/core/requester'
require 'rbslicer/core/handler_response'
require 'rbslicer/utils/validators'
require 'rbslicer/utils/data_utils'
require 'json'

module Rbslicer
  class SlicingDiceAPI
    attr_reader :status_code, :headers
    # Public: Instantiate a new SlicingDice object
    #
    # token(String) - Token to access API
    # timeout(Integer) - Define timeout to request, defaults 60 secs(Optional).
    # use_ssl(TrueClass or FalseClass) - Define if the request uses
    #   verification SSL for HTTPS requests. Defaults False.(Optional)
    def initialize(
        master_key = nil, custom_key = nil, read_key = nil,
          write_key = nil, timeout = 60, use_ssl = true)
      @requester = Core::Requester.new(use_ssl, timeout)
      @key = organize_keys(master_key, custom_key, write_key, read_key)
      @api_key = nil
      @status_code = nil
      @headers = nil
      @req = nil
    end

    def organize_keys(master_key, custom_key, write_key, read_key)
      return {
        "master_key" => master_key,
        "custom_key" => custom_key,
        "write_key" => write_key,
        "read_key" => read_key
      }
    end

    def get_key
      if @key["master_key"] != nil
        return [@key["master_key"], 2]
      elsif @key["custom_key"] != nil
        return [@key["custom_key"], 2]
      elsif @key["write_key"] != nil
        return [@key["write_key"], 1]
      elsif @key["read_key"] != nil
        return [@key["read_key"], 0]
      end
      raise Exceptions::SlicingDiceKeysException, 'You need put a key.'
    end

    def check_key(endpoint_key_level)
      current_key_level = get_key()
      if current_key_level[1] < endpoint_key_level
        raise Exceptions::SlicingDiceKeysException, 'This key is not allowed '\
          'to perform this operation.'
      end
      @api_key = current_key_level[0]
    end

    # Public: Effectively makes the request
    #
    # url(String) - A url String to make request
    # req_type(String) - The request type, should be get, post, put or delete
    # key_level(Integer) - The minimum key level required to make the request
    # data(Hash) - A Hash to send in request
    #
    # Returns a request result
    def make_request(url, req_type, key_level,  data: nil)
      check_key key_level
      headers = {
        'Content-Type' => 'application/json',
        'Authorization' => @api_key
      }
      @req = @requester.run url, headers, req_type, data: data
      handler_request!
    end

    # Public: Check if all request was successful and populate properties
    #
    # Returns:
    #     a Hash with result
    def handler_request!
      response = Core::HandlerResponse.new(
        @req.body,
        @req.code,
        @req.header.to_hash.inspect
      )
      populate_properties! if response.request_successful? && check_request
    end

    # Public: Check if request dont't have client or server errors
    #
    # Returns true if don't have errors
    def check_request
      if @req.code.to_i.between?(400, 499)
        raise Exceptions::SlicingDiceHTTPError, "Client Error "\
          "#{@req.code} (#{@req.message})."
      elsif @req.code.to_i.between?(500, 600)
        raise Exceptions::SlicingDiceHTTPError, "Server Error "\
          "#{@req.code} (#{@req.message})."
      else
        true
      end
    end

    # Public: Populates properties after request make
    def populate_properties!
      @status_code = @req.code
      @headers = @req.header.to_hash.inspect
      JSON.parse(@req.body, quirks_mode: true)
    end
  end
end
