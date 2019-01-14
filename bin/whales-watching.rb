#!/usr/bin/env ruby

require 'bundler/setup'
require 'bitmex'

product = (ARGV.first || 'XBTUSD')
limit = (ARGV[1] || 10).to_i
puts "==> Filter trades > #{limit} #{product}"

client = Bitmex::Client.new
client.listen trade: product do |trade|
  puts trade if trade.homeNotional > limit
end
