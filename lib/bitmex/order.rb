module Bitmex
  # Order Placement, Cancellation, Amending, and History
  # @author Iulian Costan
  class Order < Base
    attr_reader :orderID, :clOrdID

    def initialize(rest, websocket = nil, orderID = nil, clOrdID = nil)
      super rest, websocket
      @orderID = orderID
      @clOrdID = clOrdID
    end

    # Get your orders
    # @!macro bitmex.filters
    # @return [Array] the orders
    # @yield [Hash] the order
    def all(filters = {}, &ablock)
      if block_given?
        websocket.listen order: filters[:symbol], &ablock
      else
        rest.get order_path, params: filters, auth: true
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
      rest.put order_path, params: params
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
      rest.post order_path, params: params
    end

    # Cancel an order
    # @param text [String] Optional cancellation annotation. e.g. 'Spread Exceeded'.
    # @return [Bitmex::Mash] the canceled order
    def cancel(text = nil)
      params = { orderID: orderID, clOrdID: clOrdID, text: text }
      rest.delete order_path, params: params do |response|
        # a single order only
        response_handler(response).first
      end
    end

    private

    def order_path(action = '')
      rest.base_path 'order', action
    end
  end
end
