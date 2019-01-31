module Bitmex
  # Websocket API
  # https://www.bitmex.com/app/wsAPI
  class Websocket
    # Create new websocket instance
    # @param url the URL to connect to
    # @return new websocket instance
    def initialize(url)
      @callbacks = {}
      @faye = Faye::WebSocket::Client.new url
      @faye.on :open do |event|
        # puts [:open, event]
      end
      @faye.on :error do |event|
        raise [:error, event.data]
      end
      @faye.on :close do |event|
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

    # Subscribe to a specific topic and optionally filter by symbol
    # @param topic [String] topic to subscribe to e.g. 'trade'
    # @param symbol [String] symbol to filter by e.g. 'XBTUSD'
    def subscribe(topic, symbol = nil, &callback)
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

    private

    def subscription(topic, symbol)
      subscription = topic.to_s
      subscription += ":#{symbol}" if symbol
      subscription
    end
  end
end
