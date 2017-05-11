# coding: utf-8

require 'json'
require 'rbslicer/exceptions'
require 'rbslicer/core/helper_handler_exceptions'

module Core
  # Public: Find API errors in response data
  class HandlerResponse
    # Public: Initialize HandlerResponse object
    #
    # result - A JSON with request result data
    # status_code - A Integer with request status
    # headers - A hash with request headers
    def initialize(result, status_code, headers)
      @status_code = status_code
      @headers = headers
      @result = JSON.parse(result, quirks_mode: true)
    rescue JSON::ParserError
      raise Exceptions::InternalServerException
    end

    # Public: Find API errors and raise exceptions
    #
    # Returns true if all is ok
    def raise_exception(error)
      code = error['code'].to_i
      hash_errors = HelperHandlerExceptions::SLICER_EXCEPTIONS
      if hash_errors.key?(code)
        raise hash_errors[code], error
      else
        raise Exceptions::SlicingDiceHTTPError, error
      end
    end

    # Public: Check if JSON result have errors
    #
    # Return true if result request is ok
    def request_successful?
      if @result.key?('errors')
        error = @result['errors'][0]
        raise_exception(error)
      end
      true
    end

    private :raise_exception
  end
end
