require 'faye/websocket'
require 'eventmachine'

module Bitmex
  # Websocket API support
  # https://www.bitmex.com/app/wsAPI
  class Websocket
    attr_reader :host, :api_key, :api_secret

    # Create new websocket instance
    # @param host [String] the underlying host to connect to
    # @param api_key [String] the api key
    # @param api_secret [String] the api secret
    # @return [Bitmex::Websocket] new websocket instance
    def initialize(host, api_key: nil, api_secret: nil)
      @host = host
      @api_key = api_key
      @api_secret = api_secret

    end

    # Subscribe to a specific topic and optionally filter by symbol
    # @param topic [String] topic to subscribe to e.g. 'trade'
    # @param symbol [String] symbol to filter by e.g. 'XBTUSD'
    # @yield [Array] data payload
    def subscribe(topic, symbol = nil, auth: false, &callback)
      raise 'callback block is required' unless block_given?

      @callbacks[topic.to_s] = callback

      payload = { op: :subscribe, args: [subscription(topic, symbol)] }
      @faye.send payload.to_json.to_s
    end

    # Unsubscribe from a specific topic and symbol
    # @param topic (see #subscribe)
    # @param symbol (see #subscribe)
    def unsubscribe(topic, symbol = nil)
      @callbacks[topic.to_s] = nil

      payload = { op: :unsubscribe, args: [subscription(topic, symbol)] }
      @faye.send payload.to_json.to_s
    end

    # Listen to generic topics
    # @param topics [Hash] topics to listen to e.g. { trade: "XBTUSD" }
    # @yield [data] data pushed via websocket
    def listen(topics, &ablock)
      EM.run do
        connect

        topics.each do |topic, symbol|
          subscribe topic, symbol, &ablock
        end
      end
    end

    # Stop websocket listener
    def stop
      EM.stop_event_loop
    end

    private

    def connect
      @faye = Faye::WebSocket::Client.new realtime_url, [], headers: headers
      @callbacks = {}
      @faye.on :open do |_event|
        # puts [:open, event.data]
      end
      @faye.on :error do |event|
        raise event.message
      end
      @faye.on :close do |_event|
        # puts [:close, event.reason]
        @faye = nil
      end
      @faye.on :message do |event|
        json = JSON.parse event.data
        topic = json['table']
        data = json['data']

        callback = @callbacks[topic]
        if callback
          data&.each do |payload|
            callback.yield Bitmex::Mash.new(payload)
          end
        else
          puts "==> #{event.data}"
        end
      end
    end

    def headers
      Bitmex.headers api_key, api_secret, 'GET', '/realtime', ''
    end

    # def authenticate
    #   if api_key && api_secret
    #     expires = Time.now.utc.to_i + 60
    #     signature = Bitmex.signature(api_secret, 'GET', '/realtime', expires, '')
    #     authentication = { op: :authKeyExpires, args: [api_key, expires, signature] }
    #     @faye.send authentication.to_json.to_s
    #   end
    # end

    def subscription(topic, symbol)
      subscription = topic.to_s
      subscription += ":#{symbol}" if symbol
      subscription
    end

    def realtime_url
      "wss://#{host}/realtime"
    end
  end
end
