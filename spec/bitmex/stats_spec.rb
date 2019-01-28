require 'spec_helper'

RSpec.describe Bitmex::Client do
  subject { Bitmex::Client.new testnet: true, api_key: ENV['API_KEY'], api_secret: ENV['API_SECRET'] }

  it '#current' do
    stats = subject.stats.current
    expect(stats.size).to eq 47
    expect(stats.first.rootSymbol).to eq 'A50'
    expect(stats.first.currency).to eq 'XBt'
    expect(stats.first.openInterest).to eq 0
    expect(stats.first.openValue).to eq 0
  end

  it '#history' do
    history = subject.stats.history
    expect(history.size).to eq 17582
    expect(history.first.rootSymbol).to eq 'XBT'
    expect(history.first.currency).to eq 'XBt'
    expect(history.first.turnover).to eq 0
  end

  it '#history_usd' do
    history = subject.stats.history_usd
    expect(history.size).to eq 43
    expect(history.first.rootSymbol).to eq 'A50'
    expect(history.first.currency).to eq 'USD'
    expect(history.first.turnover).to eq 124596880
  end
end
