module Bitmex
  class Client
    include HTTParty
    base_uri 'https://testnet.bitmex.com/api/v1'

    def initialize
      @options = {}
    end

    def get_instruments
      execute '/instrument/active' do |response|
        response.to_a.map do |i|
          Hashie::Mash.new i
        end
      end
    end

    def stats
      execute '/stats' do |response|
        response.to_a.map do |s|
          Hashie::Mash.new s
        end
      end
    end

    private

    def execute(uri, &ablock)
      response = self.class.get uri, query: { count: 10 }
      fail response.message unless response.success?
      yield response
    end
  end
end
