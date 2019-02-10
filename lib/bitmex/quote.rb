module Bitmex
  # Best Bid/Offer Snapshots & Historical Bins
  # Looks like all REST API methods return '403 Forbidden' but Web socket API works just fine.
  # @author Iulian Costan
  class Quote < Base
    # Get all quotes
    # @!macro bitmex.filters
    # @return [Array] the quotes
    # @yield [Hash] the quote data
    def all(filters = {}, &ablock)
      if block_given?
        websocket.listen quote: filters[:symbol], &ablock
      else
        rest.get quotes_path, params: filters
      end
    end

    # Get previous quotes in time buckets
    # @param bin_size ['1m','5m','1h','1d'] the interval to bucket by
    # @!macro bitmex.filters
    # @return [Array] the quotes by bucket
    # @yield [Hash] the quote data
    def bucketed(bin_size = '1h', filters = {}, &ablock)
      check_binsize bin_size

      if block_given?
        topic = { "quoteBin#{bin_size}": filters[:symbol] }
        websocket.listen topic, &ablock
      else
        params = filters.merge binSize: bin_size
        rest.get quotes_path(:bucketed), params: params
      end
    end

    private

    def quotes_path(action = '')
      rest.base_path :quote, action
    end
  end
end
