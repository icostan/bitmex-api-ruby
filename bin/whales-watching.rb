#!/usr/bin/env ruby

require 'json'
require 'faye/websocket'
require 'eventmachine'

product = (ARGV.first || 'BTCUSD')
limit = (ARGV[1] || 10).to_i
puts "==> Filter trades > #{limit} #{product}"

EM.run {
  ws = Faye::WebSocket::Client.new('wss://www.bitmex.com/realtime')

  ws.on :open do |event|
    p [:open]
    ws.send "{\"op\": \"subscribe\", \"args\": [\"trade:#{product}\"]}"
  end

  ws.on :message do |event|
    json = JSON.parse event.data
    data = json['data']

    data && data.select{ |trade| trade['homeNotional'].to_i > limit }.each do |trade|
      p trade
    end
  end

  ws.on :error do |event|
    p [:error, event.data]
  end

  ws.on :close do |event|
    p [:close, event.code, event.reason]
    ws = nil
  end
}
