module Bitmex
  # Summary of Open and Closed Positions
  # @author Iulian Costan
  class Position < Base
    attr_reader :symbol

    # A new instance of Position
    # @param client [Bitmex::Client] the HTTP client
    # @param symbol [String] the symbol of the underlying position
    def initialize(client, symbol = 'XBTUSD')
      super client
      @symbol = symbol
    end

    # Get your positions
    # @return [Array] the list of positions
    def all
      client.get position_path, auth: true do |response|
        response_handler response
      end
    end

    # Enable isolated margin or cross margin per-position
    # @param enabled [true, false] true for isolated margin, false cross margin
    # @return [Hash] the updated position
    def isolate(enabled: true)
      path = position_path(:isolate)
      params = { symbol: symbol, enabled: enabled }
      client.post path, params: params do |response|
        response_handler response
      end
    end

    # Choose leverage for a position
    # @param leverage [0-100] leverage value. send a number between 0.01 and 100 to enable isolated margin with a fixed leverage. send 0 to enable cross margin
    # @return [Hash] the updated position
    def leverage(leverage)
      raise ArgumentError, "leverage #{leverage} is outside of [0..100] range" unless (0..100).include? leverage

      path = position_path(:leverage)
      params = { symbol: symbol, leverage: leverage }
      client.post path, params: params do |response|
        response_handler response
      end
    end

    # Update your risk limit
    # @param risk_limit [Double] new risk limit, in Satoshis.
    # @return [Hash] the updated position
    def risk_limit(risk_limit)
      path = position_path(:riskLimit)
      params = { symbol: symbol, riskLimit: risk_limit }
      client.post path, params: params do |response|
        response_handler response
      end
    end

    # Transfer equity in or out of a position
    # @example Transfer 1000 Satoshi
    #   position = client.position('XBTUSD').transfer_margin 1000
    # @param amount [Double] amount to transfer, in Satoshis. may be negative.
    # @return [Hash] the updated position
    def transfer_margin(amount)
      path = position_path(:transferMargin)
      params = { symbol: symbol, amount: amount }
      client.post path, params: params do |response|
        response_handler response
      end
    end

    private

    def position_path(action = '')
      client.base_path :position, action
    end
  end
end
