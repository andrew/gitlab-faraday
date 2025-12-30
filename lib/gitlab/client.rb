# frozen_string_literal: true

require 'cgi/escape'

module Gitlab
  class Client < API
    Dir[File.expand_path('client/*.rb', __dir__)].each { |f| require f }

    include AccessRequests
    include ApplicationSettings
    include Avatar
    include AwardEmojis
    include Boards
    include Branches
    include BroadcastMessages
    include BuildVariables
    include Builds
    include Commits
    include ContainerRegistry
    include Deployments
    include Environments
    include EpicIssues
    include Epics
    include Events
    include Features
    include GroupBadges
    include GroupBoards
    include GroupLabels
    include GroupMilestones
    include Groups
    include IssueLinks
    include Issues
    include Jobs
    include Keys
    include Labels
    include Lint
    include Markdown
    include MergeRequestApprovals
    include MergeRequests
    include MergeTrains
    include Milestones
    include Namespaces
    include Notes
    include Packages
    include PipelineSchedules
    include PipelineTriggers
    include Pipelines
    include ProjectBadges
    include ProjectClusters
    include ProjectExports
    include ProjectReleaseLinks
    include ProjectReleases
    include Projects
    include ProtectedTags
    include RemoteMirrors
    include Repositories
    include RepositoryFiles
    include RepositorySubmodules
    include ResourceLabelEvents
    include ResourceStateEvents
    include Runners
    include Search
    include Services
    include Sidekiq
    include Snippets
    include SystemHooks
    include Tags
    include Templates
    include Todos
    include Users
    include UserSnippets
    include Versions
    include Wikis

    def inspect
      inspected = super
      inspected = redact_private_token(inspected, @private_token) if @private_token
      inspected
    end

    def url_encode(url)
      CGI.escapeURIComponent(url.to_s)
    end

    def redact_private_token(inspected, private_token)
      redacted = only_show_last_four_chars(private_token)
      inspected.sub(%(@private_token="#{private_token}"), %(@private_token="#{redacted}"))
    end

    def only_show_last_four_chars(token)
      return '****' if token.size <= 4

      "#{'*' * (token.size - 4)}#{token[-4..]}"
    end
  end
end
