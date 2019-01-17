require 'json'
require 'faye/websocket'
require 'eventmachine'
require 'logger'

module Bitmex
  class Client
    include HTTParty
    # logger ::Logger.new(STDOUT), :debug, :curl

    ANNOUNCEMENT_ARGS = %w(urgent).freeze
    APIKEY_ARGS = %w().freeze
    CHAT_ARGS = %w(channels connected).freeze
    EXECUTION_ARGS = %w(tradehistory).freeze
    FUNDING_ARGS = %w().freeze
    GLOBALNOTIFICATION_ARGS = %w().freeze
    INSTRUMENT_ARGS = %w(active activeandindices activeintervals compositeindex indices).freeze
    INSURANCE_ARGS = %w().freeze
    LEADERBOARD_ARGS = %w().freeze
    LIQUIDATION_ARGS = %w().freeze
    ORDER_ARGS = %w().freeze
    ORDERBOOK_ARGS = %w(L2).freeze
    POSITION_ARGS = %w().freeze
    QUOTE_ARGS = %w(bucketed).freeze
    SCHEMA_ARGS = %w(websockethelp).freeze
    SETTLEMENT_ARGS = %w().freeze
    STATS_ARGS = %w(history historyusd).freeze
    TRADE_ARGS = %w(bucketed).freeze
    USER_ARGS = %w().freeze
    USEREVENT_ARGS = %w().freeze

    TESTNET_HOST = 'testnet.bitmex.com'.freeze
    MAINNET_HOST = 'www.bitmex.com'.freeze

    AUTHORIZATIONS = %w(apikey execution position globalnotification order leaderboard quote user userevent)

    attr_reader :host, :api_key, :api_secret

    def initialize(testnet: false, api_key: nil, api_secret: nil)
      @host = testnet ? TESTNET_HOST : MAINNET_HOST
      @api_key = api_key
      @api_secret = api_secret
    end

    def orderbook(symbol)
      execute 'orderbook', 'L2', { symbol: symbol } do |response|
        response.to_a.map do |s|
          Bitmex::Mash.new s
        end
      end
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
        # puts subscription

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
          # p [:close, event.reason]
          ws = nil
        end
      end
    end

    def user
      Bitmex::User.new self
    end

    #
    # Stop websocket listener
    #
    def stop
      EM.stop_event_loop
    end

    def get(path, params: {}, auth: false)
      options = {}
      options[:query] = params unless params.empty?
      options[:headers] = headers 'GET', path, '' if auth

      response = self.class.get "#{domain_url}#{path}", options
      yield response
    end

    def put(path, params: {}, auth: true, json: true)
      body = json ? params.to_json.to_s : URI.encode_www_form(params)

      options = {}
      options[:body] = body
      options[:headers] = headers 'PUT', path, body, json: json if auth

      response = self.class.put "#{domain_url}#{path}", options
      puts response.body
      yield response
    end

    private

    def method_missing(m, *args, &ablock)
      name = m.to_s.gsub '_', ''
      params = args.first || {}
      type = params&.delete :type
      types = self.class.const_get "#{name.upcase}_ARGS"
      check! type, types

      params[:auth] = auth_required? name

      execute name, type, params do |response|
        # p response.body
        if response.parsed_response.is_a? Array
          response.to_a.map do |s|
            Bitmex::Mash.new s
          end
        else
          Bitmex::Mash.new response
        end
      end
    end

    def auth_required?(action)
      AUTHORIZATIONS.include? action
    end

    def execute(endpoint, type, params, &ablock)
      url = "#{rest_url}/#{endpoint}/#{type}"
      path = "/api/v1/#{endpoint}/#{type}"
      auth = params&.delete(:auth)
      params = nil if params&.empty?

      options = { query: params }
      options[:headers] = headers 'GET', path, '' if auth

      response = self.class.get url, options
      fail response.body unless response.success?
      yield response
    end

    def headers(verb, path, body, json: true)
      raise 'api_key and api_secret are required' unless api_key || api_secret

      expires = Time.now.utc.to_i + 60
      headers = {
        'api-expires' => expires.to_s,
        'api-key' => api_key,
        'api-signature' => Bitmex.signature(api_secret, verb, path, expires, body)
      }
      if json
        headers['Content-Type'] = 'application/json'
      else
        headers['Content-Type'] = 'application/x-www-form-urlencoded'
      end
      headers
    end

    def check!(type, types)
      return true if type.nil? or type == ''
      raise ArgumentError, "invalid argument #{type}, only #{types} are supported" if !types.include?(type.to_s)
    end

    def rest_url
      "https://#{host}/api/v1"
    end

    def domain_url
      "https://#{host}"
    end

    def realtime_url
      "wss://#{host}/realtime"
    end
  end
end
