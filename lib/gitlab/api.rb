# frozen_string_literal: true

module Gitlab
  class API < Request
    attr_accessor(*Configuration::VALID_OPTIONS_KEYS)
    alias auth_token= private_token=

    def initialize(options = {})
      options = Gitlab.options.merge(options)
      (Configuration::VALID_OPTIONS_KEYS + [:auth_token]).each do |key|
        send("#{key}=", options[key]) if options[key]
      end
      request_defaults(sudo)
    end
  end
end
