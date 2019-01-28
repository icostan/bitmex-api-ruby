require 'spec_helper'

RSpec.describe Bitmex::Client do
  subject { Bitmex::Client.new testnet: true, api_key: ENV['API_KEY'], api_secret: ENV['API_SECRET'] }

  it '#announcement' do
    expect(subject.announcement).to be_kind_of Array
    expect(subject.announcement type: :urgent).to be_kind_of Array
  end

  it '#apikey' do
    expect(subject.apikey.first['name']).to eq 'bitmex-api-ruby'
  end

  it '#chat' do
    expect(subject.chat).to be_kind_of Array
  end

  describe '#execution' do
    it 'default' do
      orders = subject.execution
      expect(orders.size).to be >= 5
    end
    it 'tradehistory' do
      orders = subject.execution type: :tradehistory
      expect(orders.size).to be >= 1
    end
  end

  it '#funding' do
    expect(subject.funding).to be_kind_of Array
  end

  xit '#global_notification' do
    expect(subject.global_notification).to be_kind_of Array
  end

  it '#instrument' do
    instruments = subject.instrument
    instrument = instruments.first
    expect(instrument).to be_a Bitmex::Mash
    expect(instrument.rootSymbol).to include 'XBT'

    instruments = subject.instrument type: :active
    expect(instruments).to be_kind_of Array

    expect { subject.instrument(type: :bad) }.to raise_error ArgumentError
  end

  it '#insurance' do
    expect(subject.insurance).to be_kind_of Array
  end

  it '#leaderboard' do
    leaders = subject.leaderboard
    expect(leaders.size).to eq 25
  end

  it '#liquidation' do
    expect(subject.liquidation).to be_kind_of Array
  end

  it '#order' do
    orders = subject.order
    expect(orders.size).to eq 2
  end

  it '#orderbook' do
    expect(subject.orderbook 'XBTUSD').to be_kind_of Array
  end

  describe '#position' do
    it 'default' do
      positions = subject.position
      expect(positions).to be_kind_of Array
      expect(positions.size).to eq 0
    end
  end

  xit '#quote' do
    quotes = subject.quote
    expect(quotes.size).to eq 1
  end

  it '#schema' do
    expect(subject.schema).to be_kind_of Hash
  end

  it '#settlement' do
    expect(subject.settlement).to be_kind_of Array
  end

  describe '#listen' do
    it 'to single topic' do
      subject.listen trade: 'XBTUSD' do |trade|
        # puts trade
        expect(trade.symbol).to eq 'XBTUSD'
        subject.stop
      end
    end
    it 'to multiple topics' do
      subject.listen instrument: 'XBTUSD' do |data|
        # puts data
        expect(data.symbol).to eq 'XBTUSD' if data.topic == 'instrument'
        subject.stop
      end
    end
  end
end
