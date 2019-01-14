require 'spec_helper'

RSpec.describe Bitmex::Client do
  subject { Bitmex::Client.new testnet: true }

  it '#announcement' do
    expect(subject.announcement).to be_kind_of Array
    expect(subject.announcement type: :urgent).to be_kind_of Array
  end

  it '#apikey'

  it '#chat' do
    expect(subject.chat).to be_kind_of Array
  end

  it '#execution'

  it '#funding' do
    expect(subject.funding).to be_kind_of Array
  end

  it '#global_notification'

  it '#instrument' do
    instruments = subject.instrument
    expect(instruments).to be_kind_of Array
    instrument = instruments.first
    expect(instrument).to be_a Hashie::Mash
    expect(instrument.rootSymbol).to include 'XBT'

    instruments = subject.instrument type: :active
    expect(instruments).to be_kind_of Array

    expect { subject.instrument(type: :bad) }.to raise_error ArgumentError
  end

  it '#insurance' do
    expect(subject.insurance).to be_kind_of Array
  end

  it '#leaderboard'

  it '#liquidation' do
    expect(subject.liquidation).to be_kind_of Array
  end

  it '#order'

  it '#order_book' do
    expect(subject.order_book 'XBTUSD').to be_kind_of Array
  end

  it '#position'

  it '#quote'

  it '#schema' do
    expect(subject.schema).to be_kind_of Hash
  end

  it '#settlement' do
    expect(subject.settlement).to be_kind_of Array
  end

  it '#trade' do
    trades = subject.trade symbol: 'XBTUSD', startTime: '2019-01-01', count: 10
    expect(trades.size).to eq 10
    expect(trades.first.symbol).to eq 'XBTUSD'
    expect(trades.first.timestamp).to eq '2019-01-01T00:00:02.119Z'
  end

  it '#stats' do
    stats = subject.stats
    expect(stats).to be_kind_of Array
    instrument = stats.first
    expect(instrument).to be_a Hashie::Mash
    expect(instrument.rootSymbol).to include 'A50'
    expect(instrument.openInterest).to be >= 0

    expect(subject.stats type: :history).to be_kind_of Array
    expect{ subject.stats type: :bad }.to raise_error ArgumentError
  end

  it 'user'
  it 'user_event'

  it 'listen' do
    topics = {}
    topics[:trade] = 'XBTUSD'
    topics[:chat] = ''

    subject.listen topics do |data|
      expect(data.symbol).to eq 'XBTUSD' if data.topic == 'trade'
      expect(data.user).not_to be_nil if data.topic == 'chat'

      subject.stop
    end
  end
end
