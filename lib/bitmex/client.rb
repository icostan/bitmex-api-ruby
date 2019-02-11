module Bitmex
  # Main client interface for Bitmex API.
  class Client
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
    def announcements(&ablock)
      if block_given?
        websocket.listen announcement: nil, &ablock
      else
        rest.get :announcement
      end
    end

    # Persistent API Keys for Developers
    # @return [Bitmex::Apikey] the apikey instance
    def apikey(api_key = nil)
      Bitmex::Apikey.new rest, api_key
    end

    # Trollbox Data
    # @return [Bitmex::Chat] the chat instance
    def chat
      Bitmex::Chat.new rest, websocket
    end

    # Tradeable Contracts, Indices, and History
    # @return [Bitmex::Instrument] the instrument model
    def instrument
      Bitmex::Instrument.new rest, websocket
    end

    # Get funding history
    # @!macro bitmex.filters
    # @return [Array] the history
    # @yield [Hash] the funding data
    def funding(filters = {}, &ablock)
      if block_given?
        websocket.listen funding: nil, &ablock
      else
        rest.get :funding, params: filters
      end
    end

    # Get insurance fund history
    # @!macro bitmex.filters
    # @return [Array] the history
    # @yield [Hash] the insurance data
    def insurance(filters = {}, &ablock)
      if block_given?
        websocket.listen insurance: nil, &ablock
      else
        rest.get :insurance, params: filters
      end
    end

    # Get current leaderboard
    # @param ranking [notional ROE] the ranking type
    # @return [Array] current leaders
    def leaderboard(ranking = 'notional')
      rest.get :leaderboard, params: { method: ranking }
    end

    # Get liquidation orders
    # @example Get liquidations orders
    #   liquidations = client.liquidations symbol: 'XBTUSD'
    # @example Listen for liquidation orders
    #   client.liquidations symbol: 'XBTUSD' do |liquidation|
    #     puts liquidation.inspect
    #   end
    # @!macro bitmex.filters
    # @return [Array] the liquidations
    # @yield [Hash] the liquidation data
    def liquidations(filters = {}, &ablock)
      if block_given?
        websocket.listen liquidation: filters[:symbol], &ablock
      else
        rest.get :liquidation, params: filters
      end
    end

    # Order Placement, Cancellation, Amending, and History
    # @return [Bitmex::Order] the order model
    def orders
      # TODO: use class method
      Bitmex::Order.new rest, websocket
    end

    # Get an order by id
    # @param orderID [String] the order #
    # @param clOrdID [String] the client order #
    # @return [Bitmex::Order] the order model
    def order(orderID: nil, clOrdID: nil)
      raise ArgumentError, 'either orderID or clOrdID is required' if orderID.nil? && clOrdID.nil?

      Bitmex::Order.new rest, websocket, orderID, clOrdID
    end

    # Get current Level 2 orderbook in vertical format
    # @example Get the first level
    #   orderbook = client.orderbook 'XBTUSD', depth: 1
    # @example Listen to orderbook changes
    #   client.orderbook 'XBTUSD' do |orderbook|
    #     puts orderbook.inspect
    #   end
    # @param symbol [String] instrument symbol, send a series (e.g. XBT) to get data for the nearest contract in that series
    # @param depth [Integer] orderbook depth per side. send 0 for full depth.
    # @return [Array] the orderbook
    # @yield [Hash] the orderbook data
    def orderbook(symbol, depth: 25, &ablock)
      raise ArgumentError, 'symbol is required' unless symbol

      if block_given?
        websocket.listen orderBookL2: symbol, &ablock
      else
        rest.get 'orderbook/L2', params: { symbol: symbol, depth: depth }
      end
    end

    # Summary of Open and Closed Positions
    # @return [Array] the list of positions
    def positions
      # TODO: use class method
      Bitmex::Position.new rest, websocket
    end

    # Get an open position
    # @param symbol [String] symbol of position
    # @return [Bitmex::Position] open position
    def position(symbol)
      Bitmex::Position.new rest, websocket, symbol
    end

    # Best Bid/Offer Snapshots & Historical Bins
    # @return [Bitmex::Quote] the quote model
    def quotes
      # TODO: use class method
      Bitmex::Quote.new rest, websocket
    end

    # Get model schemata for data objects returned by this AP
    # @return [Hash] the schema
    def schema
      rest.get :schema
    end

    # Get settlement history
    # @return [Array] the settlement history
    # @yield [Hash] the settlement data
    def settlements(&ablock)
      if block_given?
        websocket.listen settlement: nil, &ablock
      else
        rest.get :settlement
      end
    end

    # Exchange statistics
    # @return [Bitmex::Stats] the stats model
    def stats
      Bitmex::Stats.new rest
    end

    # Individual and bucketed trades
    # @return [Bitmex::Trade] the trade model
    def trades
      Bitmex::Trade.new rest, websocket
    end

    # Account operations
    # @return [Bitmex::User] the user model
    def user
      Bitmex::User.new rest, websocket
    end

    def websocket
      @websocket ||= Websocket.new host, api_key: api_key, api_secret: api_secret
    end

    def rest
      @rest ||= Rest.new host, api_key: api_key, api_secret: api_secret
    end
  end
end
