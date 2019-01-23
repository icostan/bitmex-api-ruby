module Bitmex
  # Individual and bucketed trades
  # @author Iulian Costan
  class Trade
    attr_reader :client

    # @param client [Bitmex::Client] the client object
    def initialize(client)
      @client = client
    end

    # Get all trades
    # @example Get first 10 traders starting Jan 1st for XBTUSD
    #   client.trades.all symbol: 'XBTUSD', startTime: '2019-01-01', count: 10
    # @!macro bitmex.filters
    #   @param filters [Hash] the filters to apply
    #   @option filters [String] :symbol the instrument symbol
    #   @option filters [String] :filter generic table filter, send key/value pairs {https://www.bitmex.com/app/restAPI#Timestamp-Filters Timestamp Filters}
    #   @option filters [String] :columns array of column names to fetch; if omitted, will return all columns.
    #   @option filters [Double] :count (100) number of results to fetch.
    #   @option filters [Double] :start Starting point for results.
    #   @option filters [Boolean] :reverse (false) if true, will sort results newest first.
    #   @option filters [Datetime, String] :startTime Starting date filter for results.
    #   @option filters [Datetime, String] :endTime Ending date filter for results
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

    def trades_path(action = '')
      "/api/v1/trade/#{action}"
    end
  end
end
