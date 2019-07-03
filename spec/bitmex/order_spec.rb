require 'spec_helper'

RSpec.describe Bitmex::Order do
  let(:client) { Bitmex::Client.new testnet: true, api_key: ENV['API_KEY'], api_secret: ENV['API_SECRET'] }

  describe '#all' do
    it 'with rest api' do
      orders = client.orders.all
      expect(orders.size).to be >= 1
      expect(orders.first.ordStatus).to eq 'Filled'
      expect(orders.first.orderQty).to eq 10
      expect(orders.first.side).to eq 'Sell'
    end
    it 'with rest api and query parameters' do
      orders = client.orders.all symbol: 'ETHUSD'
      expect(orders.size).to eq 0
    end
    xit 'with websocket api' do
      client.orders.all symbol: 'XBTUSD' do |data|
        expect(data.symbol).to eq 'XBTUSD'
        client.websocket.stop
      end
    end
  end

  it 'create, update, delete' do
    id = rand(1000..9999)
    order = client.orders.create 'XBTUSD', side: 'Buy', orderQty: 10, price: 2000, clOrdID: id
    expect(order.ordStatus).to eq 'New'
    expect(order.orderQty).to eq 10
    expect(order.price).to eq 2000

    sleep 1

    qty = rand(10..50)
    order = client.order(clOrdID: order.clOrdID).update orderQty: qty
    expect(order.orderQty).to eq qty

    sleep 1

    order = client.order(clOrdID: order.clOrdID).cancel
    expect(order.ordStatus).to eq 'Canceled'
  end

  it '.cancel_all'
end
