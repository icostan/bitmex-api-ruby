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
      fail response.body unless response.success?

      if response.parsed_response.is_a? Array
        response.to_a.map { |s| Bitmex::Mash.new s }
      else
        Bitmex::Mash.new response
      end
    end

    def requires!(arg, args)
      raise ArgumentError, "argument '#{arg}' is required" unless args.include? arg
    end

    def base_path(resource, action)
      "/api/v1/#{resource}/#{action}"
    end
  end
end
