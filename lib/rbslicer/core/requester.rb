# coding: utf-8

require 'net/https'
require 'uri'
require 'json'

module Core
  # Public: Make full post request
  class Requester
    def initialize(timeout)
      @timeout = timeout
    end

    # Public: Make a HTTP request.
    #
    # url(String) - A url String to make request
    # headers(Hash) - A Hash with our own headers
    # req_type(String) - The request type, should be get, post, put or delete
    # data(Hash) - A Hash to send in request
    #
    # Returns a object with result request
    def run(url, headers, req_type, data = nil, sql = false)
      begin
        uri = URI.parse(url)
        http = Net::HTTP.new(uri.host, uri.port)
        if uri.port.to_s == "443"
          http.use_ssl = true
        end
        http.read_timeout = @timeout
        http.verify_mode = OpenSSL::SSL::VERIFY_NONE
        requester = nil
        parsed_data = data

        if !sql 
          parsed_data = data.to_json
        end

        if req_type == "post"
          requester = Net::HTTP::Post.new(uri.request_uri, initheader = headers)
          requester.body = parsed_data
        elsif req_type == "put"
          requester = Net::HTTP::Put.new(uri.request_uri, initheader = headers)
          requester.body = parsed_data
        elsif req_type == "get"
          requester = Net::HTTP::Get.new(uri.request_uri, initheader = headers)
        elsif req_type == "delete"
          requester = Net::HTTP::Delete.new(uri.request_uri, initheader = headers)
        end
        http.request(requester)
      rescue Timeout::Error, Errno::EINVAL,
            Errno::ECONNRESET, EOFError, Net::HTTPBadResponse,
            Net::HTTPHeaderSyntaxError, Net::ProtocolError => e
        raise e
      end
    end
  end
end
