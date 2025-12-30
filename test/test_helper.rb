# frozen_string_literal: true

$LOAD_PATH.unshift File.expand_path('../lib', __dir__)
require 'gitlab'
require 'minitest/autorun'
require 'json'

def stub_request(method, path, fixture:, status: 200, headers: {})
  response_body = File.read(File.join(__dir__, 'fixtures', fixture))
  response_headers = { 'content-type' => 'application/json' }.merge(headers)

  stubs = Faraday::Adapter::Test::Stubs.new do |stub|
    stub.send(method, path) { [status, response_headers, response_body] }
  end

  client = Gitlab::Client.new(endpoint: 'https://gitlab.example.com/api/v4', private_token: 'test-token')
  client.instance_variable_set(:@connection, Faraday.new { |b| b.adapter :test, stubs })
  client
end
