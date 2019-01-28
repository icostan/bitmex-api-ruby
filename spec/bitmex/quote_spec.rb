require 'spec_helper'

RSpec.describe Bitmex::Quote do
  subject { Bitmex::Client.new testnet: true, api_key: ENV['API_KEY'], api_secret: ENV['API_SECRET'] }

  xit '#all' do
    quotes = subject.quotes.all
    expect(quotes.size).to eq 100
    expect(quotes.first.timestamp).to eq '2019-01-01T00:00:02.119Z'
    expect(quotes.first.symbol).to eq 'XBTUSD'
  end

  xit '#bucketed' do
    quotes = subject.quotes.bucketed
    expect(quotes.size).to eq 100
    expect(quotes.first.timestamp).to eq '2019-01-01T00:00:02.119Z'
    expect(quotes.first.symbol).to eq 'XBTUSD'
  end
end
