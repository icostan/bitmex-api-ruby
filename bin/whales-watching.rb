#!/usr/bin/env ruby

require 'bundler/setup'
require 'bitmex'

product = (ARGV.first || 'XBTUSD')
limit = (ARGV[1] || 10).to_i
puts "==> Filter trades > #{limit} #{product}"

client = Bitmex::Client.new
client.trades.all symbol: product do |trade|
  puts "#{trade.side} #{trade.homeNotional} #{trade.symbol} @ #{trade.price}" if trade.homeNotional > limit
end
