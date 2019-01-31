require 'httparty'
require 'hashie'

require 'bitmex/version'
require 'bitmex/mash'

require 'bitmex/base'
require 'bitmex/chat'
require 'bitmex/client'
require 'bitmex/trade'
require 'bitmex/stats'
require 'bitmex/quote'
require 'bitmex/position'
require 'bitmex/order'
require 'bitmex/instrument'
require 'bitmex/user'
require 'bitmex/apikey'

# Bitmex module
module Bitmex
  class Error < StandardError; end

  TESTNET_HOST = 'testnet.bitmex.com'.freeze
  MAINNET_HOST = 'www.bitmex.com'.freeze

  def self.signature(api_secret, verb, path, expires, params)
    params = '' if params.nil?
    params = params.to_s unless params.is_a? String

    data = verb + path + expires.to_s + params
    OpenSSL::HMAC.hexdigest 'SHA256', api_secret, data
  end
end
