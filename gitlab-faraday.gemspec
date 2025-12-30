# frozen_string_literal: true

require_relative 'lib/gitlab/version'

Gem::Specification.new do |spec|
  spec.name = 'gitlab'
  spec.version = Gitlab::VERSION
  spec.authors = ['Nihad Abbasov', 'Sean Edge']
  spec.email = ['mail@narkoz.me', 'asedge@gmail.com']

  spec.summary = 'Ruby wrapper and target for the GitLab API'
  spec.description = 'Ruby wrapper and target for the GitLab REST API'
  spec.homepage = 'https://github.com/NARKOZ/gitlab'
  spec.license = 'BSD-2-Clause'
  spec.required_ruby_version = '>= 3.1.0'

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = 'https://github.com/NARKOZ/gitlab'
  spec.metadata['changelog_uri'] = 'https://github.com/NARKOZ/gitlab/blob/master/CHANGELOG.md'

  spec.files = Dir['lib/**/*']
  spec.require_paths = ['lib']

  spec.add_dependency 'faraday', '>= 1.0', '< 3.0'
  spec.add_dependency 'base64'
end
