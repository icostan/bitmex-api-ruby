require 'json'
require 'faye/websocket'
require 'eventmachine'

module Bitmex
  class Client
    include HTTParty

    ANNOUNCEMENT_ARGS = %w(urgent).freeze
    CHAT_ARGS = %w(channels connected).freeze
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

    TESTNET_HOST = 'testnet.bitmex.com'.freeze
    MAINNET_HOST = 'www.bitmex.com'.freeze

    attr_reader :host

    def initialize(testnet: false)
      @host = testnet ? TESTNET_HOST : MAINNET_HOST
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
          Bitmex::Mash.new s
        end
      end
    end

    def position
    end

    def user
    end

    def user_event
    end

    #
    # WebSocket API
    #
    # https://www.bitmex.com/app/wsAPI
    #
    def listen(options, &ablock)
      EM.run do
        ws = Faye::WebSocket::Client.new realtime_url

        topics = options.map{ |key, value| "#{key}:#{value}"}
        subscription = { op: :subscribe, args: topics }

        ws.on :open do |event|
          ws.send subscription.to_json.to_s
        end

        ws.on :message do |event|
          json = JSON.parse event.data
          data = json['data']

          data&.each do |payload|
            if block_given?
              yield Bitmex::Mash.new(payload.merge topic: json['table'])
            else
              p value
            end
          end
        end

        ws.on :error do |event|
          raise [:error, event.data]
        end

        ws.on :close do |event|
          ws = nil
        end
      end
    end

    #
    # Stop websocket listener
    #
    def stop
      EM.stop_event_loop
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
            Bitmex::Mash.new s
          end
        else
          Bitmex::Mash.new response
        end
      end
    end

    def execute(endpoint, type, types, params, &ablock)
      check! type, types

      url = "#{rest_url}/#{endpoint}/#{type}"
      response = self.class.get url, query: params
      fail response.message unless response.success?
      yield response
    end

    def check!(type, types)
      return true if type.nil? or type == ''
      raise ArgumentError, "invalid argument #{type}, only #{types} are supported" if !types.include?(type.to_s)
    end

    def rest_url
      "https://#{host}/api/v1"
    end

    def realtime_url
      "wss://#{host}/realtime"
    end
  end
end
