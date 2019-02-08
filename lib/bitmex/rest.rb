module Bitmex
  # REST API support
  # https://www.bitmex.com/api/explorer/
  class Rest
    include HTTParty
    # logger ::Logger.new(STDOUT), :debug, :curl

    attr_reader :host, :api_key, :api_secret

    # Create new rest instance
    # @param host [String] the underlying host to connect to
    # @param api_key [String] the api key
    # @param api_secret [String] the api secret
    # @return [Bitmex::Rest] the REST implementation
    def initialize(host, api_key: nil, api_secret: nil)
      @host = host
      @api_key = api_key
      @api_secret = api_secret
    end

    # Execute GET request
    # @param path [String] either absolute or relative URI path
    # @param params [Hash] extra parameters to pass to GET request
    # @param auth [Boolean] if the request needs authentication
    # @return [Hash, Array] response wrapped in either array or hash
    # @yield [HTTParty::Response] the underlying response
    def get(path, params: {}, auth: false, &ablock)
      path = base_path(path) unless path.to_s.start_with?('/')

      options = {}
      options[:query] = params unless params.empty?
      options[:headers] = rest_headers 'GET', path, '' if auth

      response = self.class.get "#{domain_url}#{path}", options
      block_given? ? yield(response) : response_handler(response)
    end

    def put(path, params: {}, auth: true, json: true)
      body = json ? params.to_json.to_s : URI.encode_www_form(params)

      options = {}
      options[:body] = body
      options[:headers] = rest_headers 'PUT', path, body, json: json if auth

      response = self.class.put "#{domain_url}#{path}", options
      yield response
    end

    def post(path, params: {}, auth: true, json: true)
      body = json ? params.to_json.to_s : URI.encode_www_form(params)

      options = {}
      options[:body] = body
      options[:headers] = rest_headers 'POST', path, body, json: json if auth

      response = self.class.post "#{domain_url}#{path}", options
      yield response
    end

    def delete(path, params: {}, auth: true, json: true)
      body = json ? params.to_json.to_s : URI.encode_www_form(params)

      options = {}
      options[:body] = body
      options[:headers] = rest_headers 'DELETE', path, body, json: json if auth

      response = self.class.delete "#{domain_url}#{path}", options
      yield response
    end

    def base_path(resource, action = '')
      "/api/v1/#{resource}/#{action}"
    end

    def rest_headers(verb, path, body, json: true)
      headers = headers verb, path, body
      if json
        headers['Content-Type'] = 'application/json'
      else
        headers['Content-Type'] = 'application/x-www-form-urlencoded'
      end
      headers
    end

    def headers(verb, path, body)
      Bitmex.headers api_key, api_secret, verb, path, body
    end

    def response_handler(response)
      raise response.body unless response.success?

      if response.parsed_response.is_a? Array
        response.to_a.map { |s| Bitmex::Mash.new s }
      else
        Bitmex::Mash.new response
      end
    end

    def domain_url
      "https://#{host}"
    end
  end
end
