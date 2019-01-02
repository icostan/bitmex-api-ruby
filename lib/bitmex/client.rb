module Bitmex
  class Client
    include HTTParty

    base_uri 'https://testnet.bitmex.com/api/v1'

    ANNOUNCEMENT_ARGS = %w(urgent).freeze
    EXECUTION_ARGS = %w(tradeHistory).freeze
    FUNDING_ARGS = %w().freeze
    GLOBALNOTIFICATION_ARGS = %w().freeze
    INSTRUMENT_ARGS = %w(active activeAndIndices activeIntervals compositeIndex indices).freeze
    INSURANCE_ARGS = %w().freeze
    LEADERBOARD_ARGS = %w().freeze
    LIQUIDATION_ARGS = %w().freeze
    ORDER_ARGS = %w().freeze
    ORDERBOOK_ARGS = %w(L2).freeze
    QUOTE_ARGS = %w(bucketed).freeze
    SCHEMA_ARGS = %w(websocketHelp).freeze
    SETTLEMENT_ARGS = %w().freeze
    STATS_ARGS = %w(history historyUSD).freeze
    TRADE_ARGS = %w(bucketed).freeze

    def initialize(testnet: true)
      @options = {}
    end

    def global_notification
    end

    def leaderboard
    end

    def order
    end

    def order_book(symbol)
      execute 'orderbook', 'L2', ORDERBOOK_ARGS, symbol: symbol do |response|
        response.to_a.map do |s|
          Hashie::Mash.new s
        end
      end
    end

    def position
    end

    def user
    end

    def user_event
    end

    private

    def method_missing(m, *args, &ablock)
      name = m.to_s.gsub '_', ''
      params = args.first || {}
      type = params.delete :type
      types = self.class.const_get "#{name.upcase}_ARGS"
      execute name, type, types, params do |response|
        if response.parsed_response.is_a? Array
          response.to_a.map do |s|
            Hashie::Mash.new s
          end
        else
          Hashie::Mash.new response
        end
      end
    end

    def execute(endpoint, type, types, params, &ablock)
      check! type, types

      uri = "/#{endpoint}/#{type}"
      response = self.class.get uri, query: params
      fail response.message unless response.success?
      yield response
    end

    def check!(type, types)
      return true if type.nil? or type == ''
      raise ArgumentError, "invalid argument #{type}, only #{types} are supported" if !types.include?(type.to_s)
    end
  end
end
