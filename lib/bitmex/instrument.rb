module Bitmex
  # Tradeable Contracts, Indices, and History
  # @author Iulian Costan
  class Instrument < Base
    # Get all instruments
    # @!macro bitmex.filters
    # @return [Array] all instruments
    # @yield [Hash] the instrument
    def all(filters = {}, &ablock)
      if block_given?
        websocket.listen instrument: filters[:symbol], &ablock
      else
        rest.get instrument_path, params: filters
      end
    end

    # Get all active instruments and instruments that have expired in <24hrs.
    # @return [Array] active instruments
    def active
      rest.get instrument_path('active')
    end

    # Return all active contract series and interval pairs
    # @return [Bitmex::Mash] active intervals and symbols
    def intervals
      rest.get instrument_path('activeIntervals')
    end

    # Show constituent parts of an index.
    # @!macro bitmex.filters
    # @return [Array] the parts of an index
    def composite_index(filters = { symbol: '.XBT' })
      rest.get instrument_path('compositeIndex'), params: filters
    end

    # Get all price indices
    # @return [Array] all indices
    def indices
      rest.get instrument_path('indices')
    end

    private

    def instrument_path(action = '')
      base_path :instrument, action
    end
  end
end
