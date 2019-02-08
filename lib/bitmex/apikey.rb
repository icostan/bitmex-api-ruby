module Bitmex
  # Persistent API Keys for Developers
  # @author Iulian Costan
  class Apikey < Base
    attr_reader :api_key

    # Create new Apikey
    # @param rest [Bitmex::Rest] the rest client
    # @param api_key [String] public apikey
    def initialize(rest, api_key = nil)
      super rest
      @api_key = api_key
    end

    # Get your API Keys
    # @return [Array] the api keys
    def all
      rest.get apikey_path, auth: true do |response|
        response_handler response
      end
    end

    # NOT SUPPORTED
    # #return 403 Access Denied
    def enable
      rest.post apikey_path(:enable) do |response|
        response_handler response
      end
    end

    # NOT SUPPORTED
    # @return 403 Access Denied
    def disable
      rest.post apikey_path(:disable) do |response|
        response_handler response
      end
    end

    private

    def apikey_path(action = '')
      base_path :apiKey, action
    end
  end
end
