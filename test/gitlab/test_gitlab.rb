# frozen_string_literal: true

require 'test_helper'

class TestGitlab < Minitest::Test
  def test_version
    refute_nil Gitlab::VERSION
  end

  def test_configure
    Gitlab.configure do |config|
      config.endpoint = 'https://gitlab.example.com/api/v4'
      config.private_token = 'secret'
    end

    assert_equal 'https://gitlab.example.com/api/v4', Gitlab.endpoint
    assert_equal 'secret', Gitlab.private_token
  ensure
    Gitlab.reset
  end

  def test_client
    client = Gitlab.client(endpoint: 'https://gitlab.example.com/api/v4', private_token: 'test')
    assert_instance_of Gitlab::Client, client
  end

  def test_actions
    actions = Gitlab.actions
    assert_includes actions, :projects
    assert_includes actions, :users
    assert_includes actions, :project
    refute_includes actions, :get
    refute_includes actions, :post
  end
end
