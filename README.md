# capistrano-ops

Library of useful scripts for DevOps using capistrano with rails.

**Only supports Capistrano 3 and above**.

## Requirements

```ruby
'capistrano', '~> 3.0'
'whenever'
```

## Installation

Add the gem to your `Gemfile` after setting up Capistrano
group:

```ruby
group :development do
  gem 'capistrano', require: false
end

gem 'capistrano-ops'
```

Then `bundle` and add it to your `Capfile`

```ruby
# Capfile

require 'capistrano/ops'
```

and `initializers`

```ruby
# initializers/capistrano-ops.rb
require 'capistrano/ops'
```

## Script overview

| Script                                           | Description                                                       |
| ------------------------------------------------ | ----------------------------------------------------------------- |
| `cap <environment> backup:create`                | creates backup of postgres database on the server                 |
| `cap <environment> backup:pull`                  | download latest postgres backup from server                       |
| `cap <environment> figaro_yml:compare`           | compare local application.yml with server application.yml         |
| `cap <environment> figaro_yml:get`               | shows env vars from server application.yml configured thru figaro |
| `cap <environment> logs:rails`                   | display server log live                                           |
| `cap <environment> whenever:show_crontab`        | display server app crontab generated with whenever                |
| `cap <environment> invoke:rake TASK=<your:task>` | invoke rake task on server                                        |
| `rake pg:dump`                                   | creates postgres database backup                                  |
| `rake pg:remove_old_dumps`                       | remove old postgres backups                                       |

## Usage

for all backup task you have to setup your database.yml properly:

```
production:

  database: database_name
  username: database_username
  password: database_password
  host: database_host
  port: database_port
```

### Optional Settings for backup task

| env               | description                         |
| ----------------- | ----------------------------------- |
| NUMBER_OF_BACKUPS | number of backups to keep           |
| BACKUPS_ENABLED   | enable/disable backup task          |
| DEFAULT_URL       | for slack integration message title |
| SLACK_SECRET      | for slack integration               |
| SLACK_CHANNEL     | for slack integration               |

### use with whenever/capistrano

install whenever gem and add this to your schedule.rb

```ruby
# config/schedule.rb
# Use this file to easily define all of your cron jobs.
env :PATH, ENV['PATH']
set :output, -> { '2>&1 | logger -t whenever_cron' }

every :day, at: '2:00 am' do
  rake 'pg:dump'
end

every :day, at: '3:00 am' do
  rake 'pg:remove_old_dumps'
end
```

add this to your capfile

```ruby
# Capfile
require 'whenever/capistrano'
```

## Configuration

You can optionally specify the capistrano roles for the rake task (Defaults to `:app`):

```ruby
# Defaults to [:app]
set :rake_roles, %i[db app]
```

## Contributing

1. Fork it ( https://github.com/zauberware/capistrano-ops/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
