require 'spec_helper'

RSpec.describe Bitmex::Apikey do
  let(:client) { Bitmex::Client.new testnet: true, api_key: ENV['API_KEY'], api_secret: ENV['API_SECRET'] }

  it '#all' do
    keys = client.apikey.all
    expect(keys.size).to eq 1
    expect(keys.first['name']).to eq 'bitmex-api-ruby'
  end
end
