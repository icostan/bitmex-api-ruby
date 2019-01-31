require 'json'
require 'faye/websocket'
require 'eventmachine'
require 'logger'

module Bitmex
  class Client
    include HTTParty
    # logger ::Logger.new(STDOUT), :debug, :curl

    AUTHORIZATIONS = %w(apikey execution position globalnotification order leaderboard quote user userevent)

    attr_reader :host, :api_key, :api_secret

    # Create new client instance
    # @param testnet [Boolean] true for testnet network
    # @param api_key [String] the api key
    # @param api_secret [String] the api secret
    def initialize(testnet: false, api_key: nil, api_secret: nil)
      @host = testnet ? TESTNET_HOST : MAINNET_HOST
      @api_key = api_key
      @api_secret = api_secret
    end

    # Get site announcements
    # @return [Array] the public announcements
    def announcements
      get base_path(:announcement) do |response|
        response_handler response
      end
    end

    # Persistent API Keys for Developers
    # @return [Bitmex::Apikey] the apikey instance
    def apikey(api_key = nil)
      Bitmex::Apikey.new self, api_key
    end

    # Trollbox Data
    # @return [Bitmex::Chat] the chat instance
    def chat
      Bitmex::Chat.new self
    end

    # Tradeable Contracts, Indices, and History
    # @return [Bitmex::Instrument] the instrument model
    def instrument
      Bitmex::Instrument.new self
    end

    # Get funding history
    # @!macro bitmex.filters
    # @return [Array] the history
    def funding(filters = {})
      get base_path(:funding), params: filters do |response|
        response_handler response
      end
    end

    # Get insurance fund history
    # @!macro bitmex.filters
    # @return [Array] the history
    def insurance(filters = {})
      get base_path(:insurance), params: filters do |response|
        response_handler response
      end
    end

    # Get current leaderboard
    # @param ranking [notional ROE] the ranking type
    # @return [Array] current leaders
    def leaderboard(ranking = 'notional')
      get base_path(:leaderboard), params: { method: ranking } do |response|
        response_handler response
      end
    end

    # Get liquidation orders
    # @!macro bitmex.filters
    # @return [Array] the liquidations
    def liquidations(filters = {})
      get base_path(:liquidation), params: filters do |response|
        response_handler response
      end
    end

    # Order Placement, Cancellation, Amending, and History
    # @return [Bitmex::Order] the order model
    def orders
      # TODO: use class method
      Bitmex::Order.new(self)
    end

    # Get an order by id
    # @param orderID [String] the order #
    # @param clOrdID [String] the client order #
    # @return [Bitmex::Order] the order model
    def order(orderID: nil, clOrdID: nil)
      raise ArgumentError, 'either orderID or clOrdID is required' if orderID.nil? && clOrdID.nil?

      Bitmex::Order.new(self, orderID, clOrdID)
    end

    # Get current orderbook in vertical format
    # @param symbol [String] instrument symbol, send a series (e.g. XBT) to get data for the nearest contract in that series
    # @param depth [Integer] orderbook depth per side. send 0 for full depth.
    # @return [Array] the orderbook
    def orderbook(symbol, depth: 25)
      params = { symbol: symbol, depth: depth }
      get base_path('orderbook/L2'), params: params do |response|
        response_handler response
      end
    end

    # Summary of Open and Closed Positions
    # @return [Array] the list of positions
    def positions
      # TODO: use class method
      Bitmex::Position.new(self).all
    end

    # Get an open position
    # @param symbol [String] symbol of position
    # @return [Bitmex::Position] open position
    def position(symbol)
      Bitmex::Position.new(self, symbol)
    end

    # Best Bid/Offer Snapshots & Historical Bins
    # @return [Bitmex::Quote] the quote model
    def quotes
      # TODO: use class method
      Bitmex::Quote.new self
    end

    # Get model schemata for data objects returned by this AP
    # @return [Hash] the schema
    def schema
      get base_path(:schema) do |response|
        response_handler response
      end
    end

    # Get settlement history
    # @return [Array] the settlement history
    def settlement
      get base_path(:settlement) do |response|
        response_handler response
      end
    end

    # Exchange statistics
    # @return [Bitmex::Stats] the stats model
    def stats
      Bitmex::Stats.new self
    end

    # Individual and bucketed trades
    # @return [Bitmex::Trade] the trade model
    def trades
      Bitmex::Trade.new self
    end

    # Account operations
    # @return [Bitmex::User] the user model
    def user
      Bitmex::User.new self
    end

    # Listen to generic topics
    # @param topics [Hash] topics to listen to e.g. { trade: "XBTUSD" }
    # @yield [data] data pushed via websocket
    def listen(topics, &ablock)
      EM.run do
        topics.each do |topic, symbol|
          websocket.subscribe topic, symbol, &ablock
        end
      end
    end

    #
    # Stop websocket listener
    #
    def stop
      EM.stop_event_loop
    end

    def websocket
      @websocket ||= Websocket.new realtime_url
    end

    # TODO: move these methods into rest client
    def get(path, params: {}, auth: false, &ablock)
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
      yield response
    end

    def post(path, params: {}, auth: true, json: true)
      body = json ? params.to_json.to_s : URI.encode_www_form(params)

      options = {}
      options[:body] = body
      options[:headers] = headers 'POST', path, body, json: json if auth

      response = self.class.post "#{domain_url}#{path}", options
      yield response
    end

    def delete(path, params: {}, auth: true, json: true)
      body = json ? params.to_json.to_s : URI.encode_www_form(params)

      options = {}
      options[:body] = body
      options[:headers] = headers 'DELETE', path, body, json: json if auth

      response = self.class.delete "#{domain_url}#{path}", options
      yield response
    end

    def base_path(resource, action = '')
      "/api/v1/#{resource}/#{action}"
    end

    def response_handler(response)
      fail response.body unless response.success?

      if response.parsed_response.is_a? Array
        response.to_a.map { |s| Bitmex::Mash.new s }
      else
        Bitmex::Mash.new response
      end
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
