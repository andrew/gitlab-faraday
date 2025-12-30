# frozen_string_literal: true

module Gitlab
  module Configuration
    VALID_OPTIONS_KEYS = %i[endpoint private_token user_agent sudo httparty pat_prefix body_as_json].freeze

    DEFAULT_USER_AGENT = "Gitlab Ruby Gem #{Gitlab::VERSION}"

    attr_accessor(*VALID_OPTIONS_KEYS)
    alias auth_token= private_token=

    def self.extended(base)
      base.reset
    end

    def configure
      yield self
    end

    def options
      VALID_OPTIONS_KEYS.each_with_object({}) do |key, option|
        option[key] = send(key)
      end
    end

    def reset
      self.endpoint       = ENV['GITLAB_API_ENDPOINT'] || ENV.fetch('CI_API_V4_URL', nil)
      self.private_token  = ENV['GITLAB_API_PRIVATE_TOKEN'] || ENV.fetch('GITLAB_API_AUTH_TOKEN', nil)
      self.pat_prefix     = nil
      self.httparty       = nil
      self.sudo           = nil
      self.user_agent     = DEFAULT_USER_AGENT
      self.body_as_json   = false
    end
  end
end
