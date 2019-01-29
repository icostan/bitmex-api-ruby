module Bitmex
  # Order Placement, Cancellation, Amending, and History
  # @author Iulian Costan
  class Order < Base
    attr_reader :orderID, :clOrdID

    def initialize(client, orderID = nil, clOrdID = nil)
      super client
      @orderID = orderID
      @clOrdID = clOrdID
    end

    # Get your orders
    # @!macro bitmex.filters
    #   @param filters [Hash] the filters to apply
    #   @option filters [String] :symbol the instrument symbol
    #   @option filters [String] :filter generic table filter, send key/value pairs {https://www.bitmex.com/app/restAPI#Timestamp-Filters Timestamp Filters}
    #   @option filters [String] :columns array of column names to fetch; if omitted, will return all columns
    #   @option filters [Double] :count (100) number of results to fetch
    #   @option filters [Double] :start Starting point for results
    #   @option filters [Boolean] :reverse (false) if true, will sort results newest first
    #   @option filters [Datetime, String] :startTime Starting date filter for results
    #   @option filters [Datetime, String] :endTime Ending date filter for results
    # @return [Array] the orders
    def all(filters = {})
      client.get order_path, params: filters, auth: true do |response|
        response_handler response
      end
    end

    # Amend the quantity or price of an open order
    # @param attributes [Hash] the fields to update
    # @option attributes [Integer] :orderQty Optional order quantity in units of the instrument (i.e. contracts)
    # @option attributes [Integer] :leavesQty Optional leaves quantity in units of the instrument (i.e. contracts). Useful for amending partially filled orders.
    # @option attributes [Double] :price Optional limit price for 'Limit', 'StopLimit', and 'LimitIfTouched' orders.
    # @option attributes [Double] :stopPx Optional trigger price for 'Stop', 'StopLimit', 'MarketIfTouched', and 'LimitIfTouched' orders. Use a price below the current price for stop-sell orders and buy-if-touched orders.
    # @option attributes [Double] :pegOffsetValue Optional trailing offset from the current price for 'Stop', 'StopLimit', 'MarketIfTouched', and 'LimitIfTouched' orders; use a negative offset for stop-sell orders and buy-if-touched orders. Optional offset from the peg price for 'Pegged' orders.
    # @option attributes [String] :text Optional amend annotation. e.g. 'Adjust skew'
    # @return [Bitmex::Mash] the updated order
    def update(attributes)
      params = attributes.merge orderID: orderID, origClOrdID: clOrdID
      client.put order_path, params: params do |response|
        response_handler response
      end
    end

    # Place new order
    # @param symbol [String] instrument symbol
    # @param attributes [Hash] order attributes
    # @option attributes [Buy, Sell] :side Order side. Defaults to 'Buy' unless orderQty is negative
    # @option attributes [Integer] :orderQty Order quantity in units of the instrument (i.e. contracts)
    # @option attributes [Double] :price Optional limit price for 'Limit', 'StopLimit', and 'LimitIfTouched' orders
    # @option attributes [Double] :displayQty Optional quantity to display in the book. Use 0 for a fully hidden order.
    # @option attributes [Double] :stopPx Optional trigger price for 'Stop', 'StopLimit', 'MarketIfTouched', and 'LimitIfTouched' orders. Use a price below the current price for stop-sell orders and buy-if-touched orders. Use execInst of 'MarkPrice' or 'LastPrice' to define the current price used for triggering.
    # @option attributes [String] :clOrdID Optional Client Order ID. This clOrdID will come back on the order and any related executions.
    # @option attributes [Double] :pegOffsetValue Optional trailing offset from the current price for 'Stop', 'StopLimit', 'MarketIfTouched', and 'LimitIfTouched' orders; use a negative offset for stop-sell orders and buy-if-touched orders. Optional offset from the peg price for 'Pegged' orders.
    # @option attributes [LastPeg, MidPricePeg, MarketPeg, PrimaryPeg, TrailingStopPeg] :pegPriceType Optional peg price type.
    # @option attributes [Market, Limit, Stop, StopLimit, MarketIfTouched, LimitIfTouched, MarketWithLeftOverAsLimit, Pegged] :ordType Order type. Defaults to 'Limit' when price is specified. Defaults to 'Stop' when stopPx is specified. Defaults to 'StopLimit' when price and stopPx are specified.
    # @option attributes [Day, GoodTillCancel, ImmediateOrCancel, FillOrKill] :timeInForce Time in force. Defaults to 'GoodTillCancel' for 'Limit', 'StopLimit', 'LimitIfTouched', and 'MarketWithLeftOverAsLimit' orders.
    # @option attributes [ParticipateDoNotInitiate, AllOrNone, MarkPrice, IndexPrice, LastPrice, Close, ReduceOnly, Fixed] :execInst Optional execution instructions. AllOrNone' instruction requires displayQty to be 0. 'MarkPrice', 'IndexPrice' or 'LastPrice' instruction valid for 'Stop', 'StopLimit', 'MarketIfTouched', and 'LimitIfTouched' orders.
    # @option attributes [String] :text Optional amend annotation. e.g. 'Take profit'
    # @return [Bitmex::Mash] the created order
    def create(symbol, attributes)
      params = attributes.merge symbol: symbol
      client.post order_path, params: params do |response|
        response_handler response
      end
    end

    # Cancel an order
    # @param text [String] Optional cancellation annotation. e.g. 'Spread Exceeded'.
    # @return [Bitmex::Mash] the canceled order
    def cancel(text = nil)
      params = { orderID: orderID, clOrdID: clOrdID, text: text }
      client.delete order_path, params: params do |response|
        # a single order only
        response_handler(response).first
      end
    end

    private

    def order_path(action = '')
      client.base_path 'order', action
    end
  end
end
