module Bitmex
  # Tradeable Contracts, Indices, and History
  # @author Iulian Costan
  class Instrument < Base
    # Get all instruments
    # @!macro bitmex.filters
    # @return [Array] all instruments
    def all(filters = {})
      rest.get instrument_path, params: filters do |response|
        response_handler response
      end
    end

    # Get all active instruments and instruments that have expired in <24hrs.
    # @return [Array] active instruments
    def active
      rest.get instrument_path('active') do |response|
        response_handler response
      end
    end

    # Return all active contract series and interval pairs
    # @return [Bitmex::Mash] active intervals and symbols
    def intervals
      rest.get instrument_path('activeIntervals') do |response|
        response_handler response
      end
    end

    # Show constituent parts of an index.
    # @!macro bitmex.filters
    # @return [Array] the parts of an index
    def composite_index(filters = { symbol: '.XBT' })
      rest.get instrument_path('compositeIndex'), params: filters do |response|
        response_handler response
      end
    end

    # Get all price indices
    # @return [Array] all indices
    def indices
      rest.get instrument_path('indices') do |response|
        response_handler response
      end
    end

    private

    def instrument_path(action = '')
      base_path :instrument, action
    end
  end
end
