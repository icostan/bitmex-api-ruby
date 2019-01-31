#!/usr/bin/env ruby

require 'bundler/setup'
require 'bitmex'

puts 'Listening to chat message from English channel...'

client = Bitmex::Client.new
client.listen chat: 1 do |message|
  puts "#{message.user}: #{message.message}"
end
