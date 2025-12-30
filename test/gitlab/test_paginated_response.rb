# frozen_string_literal: true

require 'test_helper'

class TestPaginatedResponse < Minitest::Test
  def test_initialize
    array = [Gitlab::ObjectifiedHash.new('id' => 1)]
    response = Gitlab::PaginatedResponse.new(array)
    assert_equal array, response
  end

  def test_array_methods
    array = [Gitlab::ObjectifiedHash.new('id' => 1), Gitlab::ObjectifiedHash.new('id' => 2)]
    response = Gitlab::PaginatedResponse.new(array)

    assert_equal 2, response.size
    assert_equal 1, response.first.id
    assert_equal 2, response.last.id
  end

  def test_parse_headers
    array = [Gitlab::ObjectifiedHash.new('id' => 1)]
    response = Gitlab::PaginatedResponse.new(array)

    headers = {
      'link' => '<https://gitlab.example.com/api/v4/projects?page=2>; rel="next", <https://gitlab.example.com/api/v4/projects?page=5>; rel="last"',
      'x-total' => '100'
    }
    response.parse_headers!(headers)

    assert response.has_next_page?
    assert response.has_last_page?
    assert_equal '100', response.total
  end

  def test_no_pagination_headers
    array = [Gitlab::ObjectifiedHash.new('id' => 1)]
    response = Gitlab::PaginatedResponse.new(array)
    response.parse_headers!({})

    refute response.has_next_page?
    refute response.has_last_page?
  end
end
