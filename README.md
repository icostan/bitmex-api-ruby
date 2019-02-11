# Bitmex API

[![Build Status](https://travis-ci.org/icostan/bitmex-api-ruby.svg?branch=master)](https://travis-ci.org/icostan/bitmex-api-ruby)
[![Maintainability](https://api.codeclimate.com/v1/badges/85c3eb58ef31dabc9159/maintainability)](https://codeclimate.com/github/icostan/bitmex-api-ruby/maintainability)
[![Test Coverage](https://api.codeclimate.com/v1/badges/85c3eb58ef31dabc9159/test_coverage)](https://codeclimate.com/github/icostan/bitmex-api-ruby/test_coverage)
[![Inline docs](http://inch-ci.org/github/icostan/bitmex-api-ruby.svg?branch=master)](http://inch-ci.org/github/icostan/bitmex-api-ruby)
[![Gem Version](https://badge.fury.io/rb/bitmex-api.svg)](https://badge.fury.io/rb/bitmex-api)
[![Yard Docs](https://img.shields.io/badge/yard-docs-blue.svg)](https://www.rubydoc.info/gems/bitmex-api)
[![License: MIT](https://img.shields.io/badge/license-MIT-blue.svg)](https://github.com/icostan/bitmex-api-ruby/blob/master/LICENSE)

Fully featured, idiomatic Ruby library for [BitMEX API](https://www.bitmex.com/app/apiOverview).

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'bitmex-api'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install bitmex-api

## Usage

### Overview

#### Bitmex client

```ruby
require 'bitmex-api'

client = Bitmex::Client.new

##### or add api_key, api_secret if you want to access private APIs
client = Bitmex::Client.new api_key: 'KEY', api_secret: 'SECRET'
```

#### REST API

Get last 10 messages in English channel:

```ruby
messages = client.chat.messages channelID: 1, count: 10, reverse: true
puts messages.first.name
```

All REST API requests return either an `Array` or `Bitmex::Mash`, a pseudo-object that extends `Hashie::Mash`.

#### Websocket API

Generic Websocket API is implemented in `#listen` method. See the list of available [Topics](https://www.bitmex.com/app/wsAPI#Subscriptions "Topics") to subscribe to.

Listen to XBTUSD trades:

```ruby
client.websocket.listen trade: 'XBTUSD' do |trade|
  puts trade.homeNotional
end
```

Or multiple topics at the same time:

```ruby
client.websocket.listen liquidation: 'XBTUSD', trade: 'XBTUSD' do |data|
  puts data
end
```

Pass blocks to methods to receive data via Websocket API.

```ruby
client.chat.messages channelID: 1 do |message|
  puts "#{message.user}: #{message.message}"
end
```

All Websocket API blocks yield a pseudo-object `Bitmex::Mash`.

### Examples

#### Whales watching

Filtering traders bigger than 10 XBT {file:bin/whales-watching.rb}

```ruby
client = Bitmex::Client.new
client.trades.all symbol: 'XBTUSD' do |trade|
  puts "#{trade.side} #{trade.homeNotional} #{trade.symbol} @ #{trade.price}" if trade.homeNotional > 10
end
```

#### Trolls listening

Listen to trollbox chat in realtime {file:bin/chat.rb}

```ruby
client = Bitmex::Client.new
client.chat.messages channelID: 1 do |message|
  puts "#{message.user}: #{message.message}"
end
```

### API Endpoints

#### Announcement

Public announcements:

```ruby
announcements = client.announcements
puts announcements.first.title

client.announcements do |announcement|
  puts announcement.content
end
```

#### API Keys

Persistent API keys for developers:

```ruby
keys = client.apikey.all
puts keys.first
```

#### Chat

Trollbox channels:

```ruby
channels = client.chat.channels
puts channels.first

client.chat.messages channelID: 1 do |message|
  puts message.user
end
```

#### Execution

Raw order and balance data:

```ruby
executions = client.user.executions count: 5
puts executions.first

client.user.executions symbol: 'XBTUSD' do |execution|
  puts execution
end
```

#### Funding

```ruby
funding = client.funding symbol: 'XBTUSD', count: 5
puts funding.first

client.funding do |funding|
  puts funding
end
```

#### Instrument

Tradeable instruments:

```ruby
instruments = client.instrument.active
puts instruments.first


client.instrument.all symbol: 'XBTUSD' do |instrument|
  puts instrument
end
```

#### Insurance

Insurance fund:

```ruby
insurance = client.insurance count: 10
puts insurance

client.insurance do |insurance|
  puts insurance.walletBalance
end
```

#### Leaderboard

Top users:

```ruby
leaders = client.leaderboard
puts leaders.first.name
```

#### Liquidation

Active liquidation:

```ruby
liquidations = client.liquidations
puts liquidations.first

client.liquidations symbol: 'XBTUSD' do |liquidation|
  puts liquidation.qty
end
```

#### Order

Get your orders.

```ruby
orders = client.orders.all
puts orders.first.side

client.orders.all symbol: 'XBTUSD' do |order|
  puts order.orderQty
end
```

Create new order, update and cancel.

```ruby
order = client.orders.create 'XBTUSD', orderQty: 100, price: 1000, clOrdID: 'YOUR_ID'
order = client.order(clOrdID: order.clOrdID).update orderQty: qty
order = client.order(clOrdID: order.clOrdID).cancel
```

#### Orderbook

Get first bid and ask:

```ruby
orderbook = client.orderbook 'XBTUSD', depth: 1
puts orderbook.first.side

client.orderbook 'XBTUSD' do |orderbook|
  puts orderbook
end
```

#### Position

Get all open positions or change leverage for an open position:

```ruby
positions = client.positions
puts positions.size

client.positions.all do |position|
  puts position.currentQty
end

position = client.position('XBTUSD').leverage 25
puts position.leverage
```

#### Quote

Best bid/ask snapshot and historical bins:

```ruby
client.quotes.all symbol: 'XBTUSD' do |quote|
  puts quote.askPrice
end

client.quotes.bucketed '1h', symbol: 'XBTUSD' do |bucket|
  puts bucket.bidSize
end
```

#### Schema

Dynamic schema for developers:

```ruby
schema = client.schema
puts schema
```

#### Settlement

Historical settlement:

```ruby
settlements = client.settlements
puts settlements.first.settlementType

client.settlements do |settlements|
  puts settlement.settledPrice
end
```

#### Stats

Exchange history:

```ruby
history = subject.stats.history
puts history.turnover
```

#### Trade

Load first 10 trades after Jan 1st for XBTUSD.

```ruby
trades = client.trades.all symbol: 'XBTUSD', startTime: '2019-01-01', count: 10
puts trades.first
```

Listen for new trades and print the ones greater than 10 XBT.

```ruby
client.trades.all symbol: product do |trade|
  puts "#{trade.side} #{trade.homeNotional} #{trade.symbol} @ #{trade.price}" if trade.homeNotional > 10
end
```

#### User

Fetch user's preferences, wallet, history, events, executions and much more.

```ruby
user = client.user.firstname
puts user.firstname

wallet = client.user.wallet
puts wallet.amount

events = client.user.events
puts events.last.type
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `bundle exec rake` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/icostan/bitmex-api. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## Code of Conduct

Everyone interacting in the Bitmex project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/icostan/bitmex-api/blob/master/CODE_OF_CONDUCT.md).
