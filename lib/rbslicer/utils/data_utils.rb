# coding: utf-8

require 'json'

module Utils
  # Public: Utils methods to fast usage
  class DataUtils
    # Public: Check if String is empty
    #
    # str - The String to be checked
    #
    # Examples
    #
    #    DataUtils.is_empty("Hello World")
    #    # => False
    #
    # Returns true if is empty
    def self.string_empty(str)
      if str.nil? && str.strip.empty? ? true : false
      end
    end

    # Public: Check if Hash has empty values or is empty
    #
    # hash_data - The Hash to be checked
    #
    # Examples
    #
    #    DataUtils.hash_empty({:name => "Kyle"})
    #    # => False
    #
    # Returns true if hash is empty
    def self.hash_empty(hash_data)
      if !hash_data.is_a?(Hash) || hash_data.empty? ? true : false
      end
    end
  end
end
