module Bitmex
  # Individual and bucketed trades
  # @author Iulian Costan
  class Trade < Base
    # Get all trades
    # @example Get first 10 traders starting Jan 1st for XBTUSD
    #   client.trades.all symbol: 'XBTUSD', startTime: '2019-01-01', count: 10
    # @!macro bitmex.filters
    # @return [Array] the trades
    # @yield [trade] the trade
    def all(filters = {}, &callback)
      if block_given?
        websocket.listen trade: filters[:symbol], &callback
      else
        rest.get trade_path, params: filters do |response|
          response_handler response
        end
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
      rest.get trade_path(:bucketed), params: params do |response|
        response_handler response
      end
    end

    private

    def trade_path(action = '')
      rest.base_path :trade, action
    end
  end
end
