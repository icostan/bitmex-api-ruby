require 'spec_helper'

RSpec.describe Bitmex::Instrument do
  let(:client) { Bitmex::Client.new testnet: true, api_key: ENV['API_KEY'], api_secret: ENV['API_SECRET'] }

  describe '#all' do
    it 'with rest api' do
      instruments = client.instrument.all count: 10
      expect(instruments.size).to eq 10
      expect(instruments.first.rootSymbol).to include 'XBT'
    end
    it 'with websocket api' do
      client.instrument.all symbol: 'XBTUSD' do |instrument|
        expect(instrument.symbol).to eq 'XBTUSD'
        client.websocket.stop
      end
    end
  end

  it '#active' do
    instruments = client.instrument.active
    expect(instruments.size).to be > 16
    expect(instruments.first.rootSymbol).to include 'XRP'
    expect(instruments.first.state).to include 'Open'
  end

  it '#indices' do
    indices = client.instrument.indices
    expect(indices.size).to be > 60
    expect(indices.first.symbol).to start_with '.'
  end

  it '#composite_index' do
    parts = client.instrument.composite_index
    expect(parts.size).to eq 100
    expect(parts.first.symbol).to eq '.XBT'
    expect(parts.first.reference).to eq 'BMI'
  end

  it '#intervals' do
    intervals = client.instrument.intervals
    expect(intervals.intervals.first).to include 'ETH'
    expect(intervals.symbols.first).to include 'ETH'
  end
end
