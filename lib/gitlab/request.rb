# frozen_string_literal: true

require 'faraday'
require 'json'

module Gitlab
  class Request
    attr_accessor :private_token, :endpoint, :pat_prefix, :body_as_json

    def self.parse(body)
      body = decode(body)

      if body.is_a?(Hash)
        ObjectifiedHash.new(body)
      elsif body.is_a?(Array)
        PaginatedResponse.new(body.map { |e| ObjectifiedHash.new(e) })
      elsif body
        true
      elsif !body
        false
      else
        raise Error::Parsing, "Couldn't parse a response body"
      end
    end

    def self.decode(response)
      response ? JSON.parse(response) : {}
    rescue JSON::ParserError
      raise Error::Parsing, 'The response is not a valid JSON'
    end

    %w[get post put patch delete].each do |method|
      define_method(method) do |path, options = {}|
        params = options.dup

        unless params[:unauthenticated]
          params[:headers] ||= {}
          params[:headers].merge!(authorization_header)
        end
        params.delete(:unauthenticated)

        jsonify_body_content(params) if body_as_json

        retries_left = params.delete(:ratelimit_retries) || 3
        begin
          response = make_request(method, path, params)
          validate(response)
        rescue Gitlab::Error::TooManyRequests => e
          retries_left -= 1
          raise e if retries_left.zero?

          wait_time = response.headers['retry-after'] || 2
          sleep(wait_time.to_i)
          retry
        end
      end
    end

    def validate(response)
      error_klass = Error.klass(response)
      raise error_klass, response if error_klass

      parsed = self.class.parse(response.body)
      parsed.client = self if parsed.respond_to?(:client=)
      parsed.parse_headers!(response.headers) if parsed.respond_to?(:parse_headers!)
      parsed
    end

    def request_defaults(sudo = nil)
      raise Error::MissingCredentials, 'Please set an endpoint to API' unless endpoint

      @sudo = sudo
    end

    def connection
      @connection ||= Faraday.new(url: endpoint) do |conn|
        conn.request :url_encoded
        conn.options.open_timeout = 30
        conn.options.timeout = 60
      end
    end

    def make_request(method, path, params)
      headers = default_headers.merge(params[:headers] || {})
      headers['Sudo'] = @sudo if @sudo
      query = params[:query] || {}
      body = params[:body]

      connection.send(method) do |req|
        req.url(path)
        req.headers = headers

        if %w[post put patch].include?(method)
          if body.is_a?(Hash) && headers['Content-Type'] == 'application/json'
            req.body = body.to_json
          elsif body.is_a?(Hash)
            req.body = URI.encode_www_form(body)
          else
            req.body = body
          end
          query.each { |k, v| req.params[k] = v }
        else
          query.each { |k, v| req.params[k] = v }
        end
      end
    end

    def default_headers
      {
        'Accept' => 'application/json',
        'Content-Type' => 'application/x-www-form-urlencoded',
        'User-Agent' => user_agent
      }
    end

    def user_agent
      @user_agent || Configuration::DEFAULT_USER_AGENT
    end

    def user_agent=(value)
      @user_agent = value
    end

    def authorization_header
      raise Error::MissingCredentials, 'Please provide a private_token or auth_token for user' unless private_token

      if private_token.size >= 64
        { 'Authorization' => "Bearer #{private_token}" }
      elsif private_token.start_with?(pat_prefix.to_s)
        { 'PRIVATE-TOKEN' => private_token }
      else
        { 'JOB-TOKEN' => private_token }
      end
    end

    def jsonify_body_content(params)
      return unless params[:body] && params[:multipart] != true
      return if params[:headers]&.key?('Content-Type')

      params[:headers] ||= {}
      params[:headers]['Content-Type'] = 'application/json'
    end
  end
end
