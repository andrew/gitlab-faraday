# Gitlab

Ruby wrapper for the GitLab REST API.

Fork of [NARKOZ/gitlab](https://github.com/NARKOZ/gitlab) updated to use Faraday instead of HTTParty and minimize dependencies.

## Installation

Add to your Gemfile:

```ruby
gem 'gitlab-faraday'
```

Or install directly:

```bash
gem install gitlab-faraday
```

## Usage

Configure your GitLab endpoint and authentication:

```ruby
Gitlab.configure do |config|
  config.endpoint       = 'https://gitlab.example.com/api/v4'
  config.private_token  = 'your-token'
end
```

Or pass options to a client instance:

```ruby
client = Gitlab.client(
  endpoint: 'https://gitlab.example.com/api/v4',
  private_token: 'your-token'
)
```

Then call API methods:

```ruby
# Get current user
Gitlab.user

# List projects
Gitlab.projects

# Get a specific project
Gitlab.project(42)

# Create an issue
Gitlab.create_issue(42, 'Bug report', description: 'Something broke')

# List merge requests
Gitlab.merge_requests(42, state: 'opened')
```

All API methods return `ObjectifiedHash` instances, so you can access attributes as methods:

```ruby
project = Gitlab.project(42)
project.name
project.default_branch
```

Paginated endpoints return `PaginatedResponse` objects that can be iterated:

```ruby
Gitlab.projects.each do |project|
  puts project.name
end

# Or use auto_paginate to fetch all pages
Gitlab.projects.auto_paginate do |project|
  puts project.name
end
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt.

## License

BSD 2-Clause License. See LICENSE for details.
