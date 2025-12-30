# frozen_string_literal: true

module Gitlab
  class ObjectifiedHash
    def initialize(hash)
      @hash = hash
      @data = hash.each_with_object({}) do |(key, value), data|
        value = self.class.new(value) if value.is_a?(Hash)
        value = value.map { |v| v.is_a?(Hash) ? self.class.new(v) : v } if value.is_a?(Array)
        data[key.to_s] = value
      end
    end

    def to_hash
      hash
    end
    alias to_h to_hash

    def inspect
      "#<#{self.class}:#{object_id} {hash: #{hash.inspect}}"
    end

    def [](key)
      data[key]
    end

    attr_reader :hash, :data

    def method_missing(method_name, *, &)
      if data.key?(method_name.to_s)
        data[method_name.to_s]
      elsif data.respond_to?(method_name)
        warn 'WARNING: Please convert ObjectifiedHash object to hash before calling Hash methods on it.'
        data.send(method_name, *, &)
      else
        super
      end
    end

    def respond_to_missing?(method_name, include_private = false)
      hash.keys.map(&:to_sym).include?(method_name.to_sym) || super
    end
  end
end
