# frozen_string_literal: true

require 'test_helper'

class TestClient < Minitest::Test
  def test_project
    client = stub_request(:get, '/projects/1', fixture: 'project.json')
    project = client.project(1)

    assert_instance_of Gitlab::ObjectifiedHash, project
    assert_equal 1, project.id
    assert_equal 'Diaspora', project.name
  end

  def test_projects
    client = stub_request(:get, '/projects', fixture: 'projects.json')
    projects = client.projects

    assert_instance_of Gitlab::PaginatedResponse, projects
    assert_equal 2, projects.size
    assert_equal 'Diaspora', projects.first.name
    assert_equal 'GitLab', projects.last.name
  end

  def test_user
    client = stub_request(:get, '/user', fixture: 'user.json')
    user = client.user

    assert_instance_of Gitlab::ObjectifiedHash, user
    assert_equal 1, user.id
    assert_equal 'john_smith', user.username
  end

  def test_url_encode
    client = Gitlab::Client.new(endpoint: 'https://gitlab.example.com/api/v4', private_token: 'test')
    assert_equal 'foo%2Fbar', client.url_encode('foo/bar')
  end

  def test_inspect_redacts_token
    client = Gitlab::Client.new(endpoint: 'https://gitlab.example.com/api/v4', private_token: 'secret-token-1234')
    inspected = client.inspect
    refute_includes inspected, 'secret-token-1234'
    assert_includes inspected, '1234'
  end
end
