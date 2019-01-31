# Bitmex API

[![Build Status](https://travis-ci.org/icostan/bitmex-api-ruby.svg?branch=master)](https://travis-ci.org/icostan/bitmex-api-ruby)
[![Maintainability](https://api.codeclimate.com/v1/badges/85c3eb58ef31dabc9159/maintainability)](https://codeclimate.com/github/icostan/bitmex-api-ruby/maintainability)
[![Test Coverage](https://api.codeclimate.com/v1/badges/85c3eb58ef31dabc9159/test_coverage)](https://codeclimate.com/github/icostan/bitmex-api-ruby/test_coverage)
[![Gem Version](https://badge.fury.io/rb/bitmex-api.svg)](https://badge.fury.io/rb/bitmex-api)
[![Inline docs](http://inch-ci.org/github/icostan/bitmex-api-ruby.svg?branch=master)](http://inch-ci.org/github/icostan/bitmex-api-ruby)

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

### Bitmex client

```ruby
require 'bitmex-api'

client = Bitmex::Client.new

# or add key and secret args if you want to access private APIs
client = Bitmex::Client.new api_key: 'KEY', api_secret: 'SECRET'
```

### REST and Websocket API

#### Using REST API

Get last 10 messages in English channel:

```ruby
messages = client.chat.messages channel_id: 1, count: 10, reverse: true
puts messages.first.name
```

#### Using Websocket API

Generic Websocket API is implemented in `Bitmex::Client#listen` method. See the list of available [Topics](https://www.bitmex.com/app/wsAPI#Subscriptions "Topics") to subscribe to.

Listen to chat messages.

```ruby
client.listen chat: 1 do |message|
  puts "#{message.user}: #{message.message}"
end
```

Listen to XBTUSD trades.

```ruby
client.listen trade: 'XBTUSD' do |trade|
  puts trade.homeNotional
end
```

Or multiple topics at the same time.

```ruby
client.listen liquidation: 'XBTUSD', trade: 'XBTUSD' do |data|
  puts data
end
```

### API Endpoints

#### Leaderboard

See the rock stars.

```ruby
leaders = client.leaderboard
puts leaders.first.name
```

#### Order

Get your orders.

```ruby
orders = client.orders.all
puts orders.size
```

Create new order, update and cancel.

```ruby
order = client.orders.create 'XBTUSD', orderQty: 100, price: 1000, clOrdID: 'YOUR_ID'
order = client.order(clOrdID: order.clOrdID).update orderQty: qty
order = client.order(clOrdID: order.clOrdID).cancel
```

#### Orderbook

Get first bid and ask.

```ruby
orderbook = client.orderbook 'XBTUSD', depth: 1
puts orderbook.first.side
```

#### Position

Get all open positions or change leverage for an open position.

```ruby
positions = client.positions
puts positions.size

position = client.position('XBTUSD').leverage 25
puts position.leverage
```

#### Stats

Exchange statistics.

```ruby
history = subject.stats.history
puts history
```

#### Trade

Load first 15 trades after Jan 1st for XBTUSD.

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
