# capistrano-ops

Library of useful scripts for DevOps using capistrano with rails.

**Only supports Capistrano 3 and above**.

## Requirements

```ruby
'capistrano', '~> 3.0'
'whenever'
'capistrano-figaro-yml'

# hint: if you use other aws-sdk gems, its possible that you have to update them too
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
# initializers/capistrano_ops.rb
require 'capistrano/ops'
```

## Script overview

| Script                                           | Description                                                       |
| ------------------------------------------------ | ----------------------------------------------------------------- |
| `cap <environment> backup:create`                | creates backup of postgres database on the server (deprecated)    |
| `cap <environment> backup:pull`                  | download latest postgres backup from server (deprecated)          |
| `cap <environment> backup:database:create`       | creates backup of postgres database on the server                 |
| `cap <environment> backup:database:pull`         | download latest postgres backup from server                       |
| `cap <environment> backup:storage:create`        | creates backup of storage on the server                           |
| `cap <environment> backup:storage:pull`          | download latest storage backup from server                        |
| `cap <environment> figaro_yml:compare`           | compare local application.yml with server application.yml         |
| `cap <environment> figaro_yml:get`               | shows env vars from server application.yml configured thru figaro |
| `cap <environment> logs:rails`                   | display server log live                                           |
| `cap <environment> whenever:show_crontab`        | display server app crontab generated with whenever                |
| `cap <environment> invoke:rake TASK=<your:task>` | invoke rake task on server                                        |
| `rake pg:dump`                                   | creates postgres database backup                                  |
| `rake pg:remove_old_dumps`                       | remove old postgres backups                                       |
| `rake storage:backup`                            | creates backup of storage                                         |
| `rake storage:remove_old_backups`                | remove old storage backups                                        |

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

| env                        | description                                                                                         |                            type/options                            |
| -------------------------- | --------------------------------------------------------------------------------------------------- | :----------------------------------------------------------------: |
| NUMBER_OF_BACKUPS          | number of backups to keep (default: 7)                                                              |                              `number`                              |
| NUMBER_OF_LOCAL_BACKUPS    | number of backups to keep locally (default: nil)                                                    |                              `number`                              |
| NUMBER_OF_EXTERNAL_BACKUPS | number of backups to keep externally (default: nil)                                                 |                              `number`                              |
| BACKUPS_ENABLED            | enable/disable backup task (default: Rails.env == 'production')                                     |                             `boolean`                              |
| EXTERNAL_BACKUP_ENABLED    | enable/disable external backup (default: false) (only if 'BACKUPS_ENABLED', needs additional setup) |                             `boolean`                              |
| DEFAULT_URL                | notification message title (default: "#{database} Backup")                                          |                              `string`                              |
| NOTIFICATION_TYPE          | for notification (default: nil)                                                                     |                    `string` (`webhook`/`slack`)                    |
| NOTIFICATION_LEVEL         | for notification (default: nil)                                                                     |                     `string` (`info`/`error`)                      |
| SLACK_SECRET               | for slack integration                                                                               | `string` (e.g. `xoxb-1234567890-1234567890-1234567890-1234567890`) |
| SLACK_CHANNEL              | for slack integration                                                                               |                    `string` (e.g. `C234567890`)                    |
| WEBHOOK_URL                | Webhook server to send message                                                                      |                      e.g `http://example.com`                      |
| WEBHOOK_SECRET             | Secret to send with uses md5-hmac hexdigest in header`x-hub-signature`                              |                                ---                                 |
| BACKUP_PROVIDER            | Backup provider (default: nil)                                                                      |                          `string` (`s3`)                           |
| S3_BACKUP_BUCKET           | S3 bucket name for backups                                                                          |                              `string`                              |
| S3_BACKUP_REGION           | S3 region for backups                                                                               |                              `string`                              |
| S3_BACKUP_KEY              | S3 access key for backups                                                                           |                              `string`                              |
| S3_BACKUP_SECRET           | S3 secret key for backups                                                                           |                              `string`                              |
| S3_BACKUP_ENDPOINT         | S3 endpoint for backups (optional, used for other S3 compatible services)                           |                              `string`                              |

### use with whenever/capistrano

install whenever gem and add this to your schedule.rb

```ruby
# config/schedule.rb
# Use this file to easily define all of your cron jobs.
env :PATH, ENV['PATH']
set :output, -> { '2>&1 | logger -t whenever_cron' }

every :day, at: '2:00 am' do
  rake 'pg:dump'
  rake 'storage:backup'
end

every :day, at: '3:00 am' do
  rake 'pg:remove_old_dumps'
  rake 'storage:remove_old_backups'
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

## Slack integration

if you want to use slack integration you have to add this to your `application.yml`

```ruby
NOTIFICATION_TYPE: 'slack'
SLACK_SECRET: '<your-slack-secret>'
SLACK_CHANNEL: '<your-slack-channel>'
```

## Webhook integration

if you want to use webhook integration you have to add this to your `application.yml`

```ruby
NOTIFICATION_TYPE: 'webhook'
WEBHOOK_URL: '<your-webhook-url>'
WEBHOOK_SECRET: '<your-webhook-secret>'
```

## Notification level

if you want to use notification level you have to add this to your `application.yml`

```ruby
NOTIFICATION_LEVEL: 'info' # default is 'error'
```

## Backups

if you want to configure the number of backups you have to add this to your `application.yml`

```ruby
NUMBER_OF_BACKUPS: 7 # default is 7 (local + external)
```

to fine tune the number of local and external backups you can use this:

```ruby
NUMBER_OF_LOCAL_BACKUPS: 7 # default is nil (local)
NUMBER_OF_EXTERNAL_BACKUPS: 7 # default is nil (local)
```

### Backup provider

if you want to use an external backup provider you have to add this to your `application.yml`

```ruby
BACKUP_PROVIDER: 's3'
S3_BACKUP_BUCKET: '<your-s3-bucket>'
S3_BACKUP_REGION: '<your-s3-region>'
S3_BACKUP_KEY: '<your-s3-key>'
S3_BACKUP_SECRET: '<your-s3-secret>'
S3_BACKUP_ENDPOINT: '<your-s3-endpoint>' # optional, used for other S3 compatible services
```

## Contributing

1. Fork it ( https://github.com/zauberware/capistrano-ops/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

```

```
