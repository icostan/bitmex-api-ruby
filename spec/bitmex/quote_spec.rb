# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Bitmex::Quote do
  let(:client) { Bitmex::Client.new testnet: true, api_key: ENV['API_KEY'], api_secret: ENV['API_SECRET'] }

  describe '#all' do
    it 'with rest api' do
      quotes = client.quotes.all
      expect(quotes.first.askPrice).to be > 0
    end
    it 'with websocket api' do
      client.quotes.all symbol: 'XBTUSD' do |quote|
        expect(quote.symbol).to eq 'XBTUSD'
        expect(quote.askPrice).to be > 0
        expect(quote.bidPrice).to be > 0
        client.websocket.stop
      end
    end
  end

  describe '#bucketed' do
    it 'via rest api' do
      buckets = client.quotes.bucketed '1h'
      expect(buckets.first.symbol).to include 'XBT'
    end
    it 'via websocket api' do
      client.quotes.bucketed '1h', symbol: 'XBTUSD' do |bucket|
        expect(bucket.symbol).to eq 'XBTUSD'
        expect(bucket.askSize).to be > 0
        expect(bucket.bidSize).to be > 0
        client.websocket.stop
      end
    end
  end
end
