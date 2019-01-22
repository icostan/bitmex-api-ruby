# Bitmex

[![Build Status](https://travis-ci.org/icostan/bitmex-api-ruby.svg?branch=master)](https://travis-ci.org/icostan/bitmex-api-ruby)
[![Maintainability](https://api.codeclimate.com/v1/badges/85c3eb58ef31dabc9159/maintainability)](https://codeclimate.com/github/icostan/bitmex-api-ruby/maintainability)
[![Test Coverage](https://api.codeclimate.com/v1/badges/85c3eb58ef31dabc9159/test_coverage)](https://codeclimate.com/github/icostan/bitmex-api-ruby/test_coverage)
[![Gem Version](https://badge.fury.io/rb/bitmex-api.svg)](https://badge.fury.io/rb/bitmex-api)

Idiomatic Ruby library for [BitMEX API](https://www.bitmex.com/app/apiOverview).

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

# or add key and secret args if you want to access private API
client = Bitmex::Client.new api_key: 'KEY', api_secret: 'SECRET'
```

### Trades

#### Using REST API

Load first 15 trades after Jan 1st for XBTUSD.

```ruby
trades = client.trade symbol: 'XBTUSD', count: 15, startTime: '2019-01-01'
trades.size
trades.first
```

#### Using Websocket API

Listen for new trades and print the ones greater than 10 XBT.

```ruby
client.listen trade: 'XBTUSD' do |trade|
  puts trade if trade.homeNotional > 10

  # when done call client.stop
  # client.stop
end
```

### Account operations

Fetch user's preferences, wallet, history, events and much more.

```ruby

user = client.user
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
