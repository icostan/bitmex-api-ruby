module Bitmex
  # Websocket API
  # https://www.bitmex.com/app/wsAPI
  class Websocket
    attr_reader :client

    # Create new websocket instance
    # @param url the URL to connect to
    # @return new websocket instance
    def initialize(url, client)
      @client = client
      @callbacks = {}

      # TODO: extract into method
      @faye = Faye::WebSocket::Client.new url, [], headers: client.headers('GET', '/realtime', '')
      @faye.on :open do |_event|
        # puts [:open, event.data]
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
    def subscribe(topic, symbol = nil, auth: false, &callback)
      raise 'callback block is required' unless block_given?

      # TODO: also try headers auth
      # authenticate

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

    def authenticate
      if api_key && api_secret
        expires = Time.now.utc.to_i + 60
        signature = Bitmex.signature(api_secret, 'GET', '/realtime', expires, '')
        authentication = { op: :authKeyExpires, args: [api_key, expires, signature] }
        @faye.send authentication.to_json.to_s
      end
    end

    def subscription(topic, symbol)
      subscription = topic.to_s
      subscription += ":#{symbol}" if symbol
      subscription
    end
  end
end
