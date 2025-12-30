# frozen_string_literal: true

require 'test_helper'

class TestError < Minitest::Test
  def test_status_mappings
    assert_equal Gitlab::Error::BadRequest, Gitlab::Error::STATUS_MAPPINGS[400]
    assert_equal Gitlab::Error::Unauthorized, Gitlab::Error::STATUS_MAPPINGS[401]
    assert_equal Gitlab::Error::Forbidden, Gitlab::Error::STATUS_MAPPINGS[403]
    assert_equal Gitlab::Error::NotFound, Gitlab::Error::STATUS_MAPPINGS[404]
    assert_equal Gitlab::Error::TooManyRequests, Gitlab::Error::STATUS_MAPPINGS[429]
    assert_equal Gitlab::Error::InternalServerError, Gitlab::Error::STATUS_MAPPINGS[500]
  end

  def test_klass_returns_correct_error
    response = Struct.new(:status).new(404)
    assert_equal Gitlab::Error::NotFound, Gitlab::Error.klass(response)
  end

  def test_klass_returns_response_error_for_unknown_status
    response = Struct.new(:status).new(418)
    assert_equal Gitlab::Error::ResponseError, Gitlab::Error.klass(response)
  end

  def test_klass_returns_nil_for_success
    response = Struct.new(:status).new(200)
    assert_nil Gitlab::Error.klass(response)
  end

  def test_missing_credentials
    error = Gitlab::Error::MissingCredentials.new('Missing token')
    assert_equal 'Missing token', error.message
  end

  def test_parsing_error
    error = Gitlab::Error::Parsing.new('Invalid JSON')
    assert_equal 'Invalid JSON', error.message
  end
end
