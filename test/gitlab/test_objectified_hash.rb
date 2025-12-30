# frozen_string_literal: true

require 'test_helper'

class TestObjectifiedHash < Minitest::Test
  def test_initialize
    hash = Gitlab::ObjectifiedHash.new('id' => 1, 'name' => 'Test')
    assert_equal 1, hash.id
    assert_equal 'Test', hash.name
  end

  def test_nested_hash
    hash = Gitlab::ObjectifiedHash.new('user' => { 'id' => 1, 'name' => 'John' })
    assert_instance_of Gitlab::ObjectifiedHash, hash.user
    assert_equal 1, hash.user.id
    assert_equal 'John', hash.user.name
  end

  def test_array_of_hashes
    hash = Gitlab::ObjectifiedHash.new('users' => [{ 'id' => 1 }, { 'id' => 2 }])
    assert_equal 2, hash.users.size
    assert_instance_of Gitlab::ObjectifiedHash, hash.users.first
    assert_equal 1, hash.users.first.id
  end

  def test_to_h
    original = { 'id' => 1, 'name' => 'Test' }
    hash = Gitlab::ObjectifiedHash.new(original)
    assert_equal original, hash.to_h
  end

  def test_bracket_accessor
    hash = Gitlab::ObjectifiedHash.new('id' => 1)
    assert_equal 1, hash['id']
  end

  def test_respond_to
    hash = Gitlab::ObjectifiedHash.new('id' => 1, 'name' => 'Test')
    assert hash.respond_to?(:id)
    assert hash.respond_to?(:name)
    refute hash.respond_to?(:nonexistent)
  end
end
