module Bitmex
  # Persistent API Keys for Developers
  # @author Iulian Costan
  class Apikey < Base
    attr_reader :api_key

    # Create new Apikey
    # @param client [Bitmex::Client] the rest client
    # @param api_key [String] public apikey
    def initialize(client, api_key = nil)
      super client
      @api_key = api_key
    end

    # Get your API Keys
    # @return [Array] the api keys
    def all
      client.get apikey_path, auth: true do |response|
        response_handler response
      end
    end

    # NOT SUPPORTED
    # #return 403 Access Denied
    def enable
      client.post apikey_path(:enable) do |response|
        response_handler response
      end
    end

    # NOT SUPPORTED
    # @return 403 Access Denied
    def disable
      client.post apikey_path(:disable) do |response|
        response_handler response
      end
    end

    private

    def apikey_path(action = '')
      base_path :apiKey, action
    end
  end
end
