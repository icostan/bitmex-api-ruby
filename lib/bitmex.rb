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
require 'bitmex/websocket'
require 'bitmex/rest'

# Bitmex module
module Bitmex
  # Bitmex standard error
  class Error < StandardError; end
  # 403 Forbidden
  class ForbiddenError < Error; end

  TESTNET_HOST = 'testnet.bitmex.com'.freeze
  MAINNET_HOST = 'www.bitmex.com'.freeze

  def self.signature(api_secret, verb, path, expires, body, query)
    body = '' if body.nil?
    body = body.to_s unless body.is_a? String

    if query != nil && query.is_a?(Hash) && !query.empty?
      path += "?#{URI.encode_www_form(query)}"
    end

    data = verb + path + expires.to_s + body
    OpenSSL::HMAC.hexdigest 'SHA256', api_secret, data
  end

  def self.headers(api_key, api_secret, verb, path, body, query)
    return {} unless api_key || api_secret

    expires = Time.now.utc.to_i + 60
    {
      'api-expires' => expires.to_s,
      'api-key' => api_key,
      'api-signature' => Bitmex.signature(api_secret, verb, path, expires, body, query)
    }
  end
end
