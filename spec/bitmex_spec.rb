require 'spec_helper'

RSpec.describe Bitmex::Client do
  it '#get_instruments' do
    instruments = subject.get_instruments
    expect(instruments).to be_kind_of Array
    instrument = instruments.first
    expect(instrument).to be_a Hashie::Mash
    expect(instrument.rootSymbol).to include 'XRP'
  end
  it '#stats' do
    stats = subject.stats
    expect(stats).to be_kind_of Array
    instrument = stats.first
    expect(instrument).to be_a Hashie::Mash
    expect(instrument.rootSymbol).to include 'A50'
    expect(instrument.openInterest).to be >= 0
  end
end
