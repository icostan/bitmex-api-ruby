module Bitmex
  # Base class for all Bitmex models
  # @author Iulian Costan
  class Base
    attr_reader :client

    # @param client [Bitmex::Client] the client object
    def initialize(client)
      @client = client
    end

    protected

    def response_handler(response)
      client.response_handler response
    end

    def requires!(arg, args)
      raise ArgumentError, "argument '#{arg}' is required" unless args.include? arg
    end

    def base_path(resource, action)
      client.base_path resource, action
    end
  end
end
