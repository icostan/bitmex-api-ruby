module Bitmex
  # Trollbox Data
  # @author Iulian Costan
  class Chat < Base
    # Get chat messages
    # @example Get last 10 messages for channel 1
    #   messages = client.chat.messages channelID: 1, count: 10, reverse: true
    # @param options [Hash] options to filter by
    # @option options [Integer] :count (100) number of results to fetch.
    # @option options [Integer] :start starting ID for results
    # @option options [Boolean] :reverse If true, will sort results newest first
    # @option options [Integer] :channelID Channel id. GET /chat/channels for ids. Leave blank for all.
    # @return [Array] the messages
    # @yield [Hash] the message
    def messages(options = { count: 100, reverse: true }, &ablock)
      if block_given?
        websocket.listen chat: options[:channelID], &ablock
      else
        rest.get chat_path, params: options
      end
    end

    # Get available channels
    # @return [Array] the available channels
    def channels
      rest.get chat_path(:channels)
    end

    # Get connected users
    # @return [Bitmex::Mash] an array with browser users in the first position and API users (bots) in the second position.
    # @yield [Hash] the stats
    def stats(&ablock)
      if block_given?
        websocket.listen connected: nil, &ablock
      else
        rest.get chat_path(:connected)
      end
    end

    # Send a chat message
    # @param message [String] the message to send
    # @param options [Hash] filter options
    # @option options [Integer] :channelID (1) channel to post to
    def send(message, options = { channelID: 1 })
      params = { message: message, channelID: options[:channelID] }
      rest.post chat_path, params: params
    end

    private

    def chat_path(action = '')
      base_path :chat, action
    end
  end
end
