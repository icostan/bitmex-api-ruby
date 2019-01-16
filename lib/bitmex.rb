require 'httparty'
require 'hashie'

require 'bitmex/version'
require 'bitmex/mash'
require 'bitmex/client'

module Bitmex
  class Error < StandardError; end

  def self.signature(api_secret, verb, path, expires, data)
    OpenSSL::HMAC.hexdigest('SHA256', api_secret, verb + path + expires.to_s + data)
  end
end
