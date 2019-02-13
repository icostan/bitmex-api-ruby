#!/usr/bin/env ruby

require 'bundler/setup'
require 'bitmex'

puts 'Triangular arbitrage: XBTUSD-ETHUSD-ETHXBT...'

client = Bitmex::Client.new
client.websocket.listen quote: ['XBTUSD', 'ETHUSD', 'ETHH19'] do |quote, state|
  # initialize
  state = {
    'max_profit' => -100, 'count' => 0,
    'XBTUSD' => {}, 'ETHUSD' => {}, 'ETHH19' => {}
  } unless state

  # update state
  state[quote.symbol] = { 'bid' => quote.bidPrice, 'ask' => quote.askPrice }
  state['count'] += 1
  puts "STATE: #{state}" if state['count']%100 == 0

  # process
  price1 = state['XBTUSD']['bid']
  price2 = state['ETHUSD']['ask']
  price3 = state['ETHH19']['bid']
  if price1 && price2 && price3
    x1 = price1
    x2 = x1 / price2
    x3 = x2 * price3
    profit = ((x3 - 1) * 10000).to_i
    if profit > state['max_profit']
      state['max_profit'] = profit
      puts "NEW PROFIT: #{profit} points"
    end
  end

  # return updated state
  state
end

#
# Capital: 1 XBT
# Short XBTUSD: 1 XBT x 3600 XBTUSD = 3600 USD
# Long ETHUSD: 3600 USD / 122 ETHUSD = 22.5 ETH
# Short ETHXBT: 22.5 ETH * 0.0339 ETHXBT = 0.7627 XBT
# P&L: XBT
#
