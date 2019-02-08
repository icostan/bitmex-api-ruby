require 'spec_helper'

RSpec.describe Bitmex::Client do
  let(:client) { Bitmex::Client.new testnet: true, api_key: ENV['API_KEY'], api_secret: ENV['API_SECRET'] }

  it '#announcement' do
    announcements = client.announcements
    expect(announcements.first.title).not_to be_nil
  end

  describe '#funding' do
    it 'with rest api' do
      funding = client.funding symbol: 'XBTUSD', count: 5
      expect(funding.size).to eq 5
      expect(funding.first.symbol).to eq 'XBTUSD'
      expect(funding.first.fundingRate).to eq 0.0005
      expect(funding.first.fundingRateDaily).to eq 0.0005
    end
    it 'with websocket api'
  end

  describe '#insurance' do
    it 'with rest api' do
      insurance = client.insurance count: 10
      expect(insurance.size).to eq 10
      expect(insurance.first.currency).to eq 'XBt'
      expect(insurance.first.walletBalance).to be >= 5103298681
    end
    it 'with websocket api'
  end

  it '#leaderboard' do
    leaders = client.leaderboard
    expect(leaders.size).to eq 25
    expect(leaders.first.name).to eq 'yoshi'
  end

  describe '#liquidations' do
    it 'with rest api' do
      liquidations = client.liquidations
      expect(liquidations.size).to be >= 0
    end
    it 'with websocket api'
  end

  describe '#orderbook' do
    it 'with rest api' do
      orderbook = client.orderbook 'XBTUSD', depth: 1
      expect(orderbook.size).to eq 2
      expect(orderbook.first.symbol).to eq 'XBTUSD'
      expect(orderbook.first.side).to eq 'Sell'
      expect(orderbook.last.side).to eq 'Buy'
    end
    it 'with websocket api'
  end

  it '#schema' do
    schema = client.schema
    expect(schema).to be_kind_of Hash
    expect(schema['Affiliate']['keys']).to eq ['account', 'currency']
  end

  describe '#settlement' do
    it 'with rest api' do
      settlement = client.settlement
      expect(settlement).to be_kind_of Array
      expect(settlement.first.symbol).to eq 'XBU24H'
      expect(settlement.first.settlementType).to eq 'Settlement'
      expect(settlement.first.settlePrice).to be_nil
    end
    it 'with ws api'
  end

  describe '#listen' do
    it 'to single topic' do
      client.websocket.listen trade: 'XBTUSD' do |trade|
        # puts trade
        expect(trade.symbol).to eq 'XBTUSD'
        client.websocket.stop
      end
    end
    it 'to multiple topics' do
      client.websocket.listen instrument: 'XBTUSD', trade: 'XBTUSD' do |data|
        # puts data
        expect(data.symbol).to eq 'XBTUSD'
        client.websocket.stop
      end
    end
  end
end
