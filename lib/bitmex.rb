require 'httparty'
require 'hashie'

require 'bitmex/version'
require 'bitmex/mash'
require 'bitmex/user'
require 'bitmex/base'
require 'bitmex/client'
require 'bitmex/trade'
require 'bitmex/stats'
require 'bitmex/quote'
require 'bitmex/position'

module Bitmex
  class Error < StandardError; end

  def self.signature(api_secret, verb, path, expires, params)
    params = '' if params.nil?
    params = params.to_s unless params.is_a? String

    data = verb + path + expires.to_s + params
    OpenSSL::HMAC.hexdigest 'SHA256', api_secret, data
  end
end
