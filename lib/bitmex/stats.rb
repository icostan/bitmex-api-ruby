module Bitmex
  # Exchange statistics
  # @author Iulian Costan
  class Stats < Base
    attr_reader :client

    # @param client [Bitmex::Client] the client object
    def initialize(client)
      @client = client
    end

    # Get exchange-wide and per-series turnover and volume statistics
    # @return [Array] the statistics
    def current
      client.get stats_path do |response|
        response_handler response
      end
    end

    # Get historical exchange-wide and per-series turnover and volume statistics
    # @return [Array] the history in XBT
    def history
      client.get stats_path(:history) do |response|
        response_handler response
      end
    end

    # Get a summary of exchange statistics in USD
    # @return [Array] the history in USD
    def history_usd
      client.get stats_path(:historyUSD) do |response|
        response_handler response
      end
    end

    private

    def stats_path(action = '')
      base_path :stats, action
    end
  end
end
