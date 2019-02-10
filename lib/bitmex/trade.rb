module Bitmex
  # Individual and bucketed trades
  # @author Iulian Costan
  class Trade < Base
    # Get all trades
    # @example Get first 10 traders starting Jan 1st for XBTUSD
    #   client.trades.all symbol: 'XBTUSD', startTime: '2019-01-01', count: 10
    # @example Listen to all XBTUSD trades
    #   client.trades.all symbol: 'XBTUSD' do |trade|
    #     puts trade.inspect
    #   end
    # @!macro bitmex.filters
    # @return [Array] the trades
    # @yield [Hash] the trade
    def all(filters = {}, &ablock)
      if block_given?
        websocket.listen trade: filters[:symbol], &ablock
      else
        rest.get trade_path, params: filters
      end
    end

    # Get previous trades in time buckets
    # @example Get last hour in 2018 and first hour in 2019 in reverse order
    #   client.trades.bucketed '1h', symbol: 'XBTUSD', endTime: Date.new(2019, 1, 1), count: 2, reverse: true
    # @example Listen to bucketed trades
    #   client.trades.bucketed '1h', symbol: 'XBTUSD' do |bucket|
    #     puts bucket.inspect
    #   end
    # @param bin_size ['1m','5m','1h','1d'] the interval to bucket by
    # @!macro bitmex.filters
    # @return [Array] the trades by bucket
    # @yield [trade] the bucketed trade
    def bucketed(bin_size = '1h', filters = {}, &ablock)
      check_binsize bin_size

      if block_given?
        topic = { "tradeBin#{bin_size}": filters[:symbol] }
        websocket.listen topic, &ablock
      else
        params = filters.merge binSize: bin_size
        rest.get trade_path(:bucketed), params: params
      end
    end

    private

    def trade_path(action = '')
      rest.base_path :trade, action
    end
  end
end
