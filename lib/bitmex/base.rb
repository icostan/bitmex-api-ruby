module Bitmex
  # Base class for all Bitmex models
  # @author Iulian Costan
  class Base
    attr_reader :rest, :websocket

    # @param rest [Bitmex::Rest] the rest implementation
    # @param websocket [Bitmex::Websocket] the websocket implementation
    def initialize(rest, websocket = nil)
      @rest = rest
      @websocket = websocket
    end

    protected

    def check_binsize(bin_size)
      raise ArgumentError, 'invalid bin_size' unless %w[1m 5m 1h 1d].include? bin_size.to_s
    end

    def response_handler(response)
      rest.response_handler response
    end

    def requires(arg, args)
      raise ArgumentError, "argument '#{arg}' is required" unless args.include? arg
    end

    def base_path(resource, action)
      rest.base_path resource, action
    end
  end
end
