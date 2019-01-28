module Bitmex
  # Individual and bucketed trades
  # @author Iulian Costan
  class Trade < Base
    # Get all trades
    # @example Get first 10 traders starting Jan 1st for XBTUSD
    #   client.trades.all symbol: 'XBTUSD', startTime: '2019-01-01', count: 10
    # @!macro bitmex.filters
    # @return [Array] the trades
    def all(filters = {})
      client.get trades_path, params: filters do |response|
        response_handler response
      end
    end

    # Get previous trades in time buckets
    # @example Get last hour in 2018 and first hour in 2019 in reverse order
    #   client.trades.bucketed '1h', symbol: 'XBTUSD', endTime: Date.new(2019, 1, 1), count: 2, reverse: true
    # @param binSize ['1m','5m','1h','1d'] the interval to bucket by
    # @!macro bitmex.filters
    # @return [Array] the trades by bucket
    def bucketed(binSize = '1h', filters = {})
      params = filters.merge binSize: binSize
      client.get trades_path(:bucketed), params: params do |response|
        response_handler response
      end
    end

    private

    def trades_path(action = '')
      base_path :trade, action
    end
  end
end
