require 'spec_helper'

RSpec.describe Bitmex::Trade do
  let(:client) { Bitmex::Client.new testnet: true }

  describe '#all' do
    it 'with rest api' do
      trades = client.trades.all symbol: 'XBTUSD', startTime: '2019-01-01', count: 10
      expect(trades.size).to eq 10
      expect(trades.first.timestamp).to eq '2019-01-01T00:00:02.119Z'
      expect(trades.first.symbol).to eq 'XBTUSD'
      expect(trades.first.side).to eq 'Sell'
      expect(trades.first.size).to eq 10
      expect(trades.first.price).to eq 3698
    end
    it 'with websocket api' do
      client.trades.all symbol: 'XBTUSD' do |trade|
        expect(trade.symbol).to eq 'XBTUSD'
        expect(trade.foreignNotional).to be >= 1
        client.websocket.stop
      end
    end
  end

  describe '#bucketed' do
    it 'with rest api' do
      trades = client.trades.bucketed '1h', symbol: 'XBTUSD', endTime: Date.new(2019, 1, 1), count: 2, reverse: true
      expect(trades.size).to eq 2

      trade = trades.first
      expect(trade.timestamp).to eq '2019-01-01T00:00:00.000Z'
      expect(trade.symbol).to eq 'XBTUSD'
      expect(trade.open).to eq 3696.5
      expect(trade.high).to eq 3715
      expect(trade.low).to eq 3669.5
      expect(trade.close).to eq 3698
      expect(trade.trades).to eq 1079
      expect(trade.volume).to eq 313350

      trade = trades.last
      expect(trade.timestamp).to eq '2018-12-31T23:00:00.000Z'
      expect(trade.symbol).to eq 'XBTUSD'
      expect(trade.open).to eq 3697
      expect(trade.high).to eq 3698
      expect(trade.low).to eq 3669
      expect(trade.close).to eq 3696.5
      expect(trade.trades).to eq 949
      expect(trade.volume).to eq 247025
    end
    it 'with websocket api'
  end
end
