# capistrano-ops - Comprehensive DevOps Utility for Rails 🛠️

The capistrano-ops gem is a valuable library, tailor-made for Rails DevOps professionals, offering an array of beneficial scripts to streamline and enhance operations with Capistrano. The focus is on seamless integration with Capistrano version 3 and above.

## Table of Contents

<details>
<summary>Click to expand</summary>

- [Main Features](#main-features)
- [Requirements](#requirements)
- [Installation](#installation)
- [Script overview](#script-overview)
- [Usage](#usage)
  - [Optional Settings for backup task](#optional-settings-for-backup-task)
  - [use with whenever/capistrano](#use-with-whenevercapistrano)
- [Configuration](#configuration)
- [Slack integration](#slack-integration)
- [Webhook integration](#webhook-integration)
- [Notification level](#notification-level)
- [Backups](#backups)
  - [Backup provider](#backup-provider)
- [Logrotate](#logrotate)
  - [Configuration](#configuration-1)
  - [Usage](#usage-1)
- [Wkhtmltopdf Setup](#wkhtmltopdf-setup)
- [Contributing](#contributing)
- [License](#license)

</details>

## Main Features:

🗃️ **Database and Storage Backups:**

- Create, pull, and manage backups of your Postgres database and server storage.
- Delegation of old backup removal for both Postgres database and server storage.

🛠️ **Configuration Management:**

- Compare `application.yml` files between local and server environments using `figaro_yml:compare`.
- Fetch server environment variables set via Figaro with `figaro_yml:get`.
- Copy local `application.yml` to the server with `figaro_yml:setup`. This task automatically triggers `figaro_yml:backup` before proceeding.
- Create a backup of the server's `application.yml` with `figaro_yml:backup`. This is automatically executed before `figaro_yml:setup` to ensure a recovery point is available.
- Roll back to the previous `application.yml` on the server using `figaro_yml:rollback`. This can be used to quickly revert changes made by `figaro_yml:setup` if needed.

📜 **Logging and Task Management:**

- Real-time viewing of Rails server logs.
- Real-time viewing of sidekiq logs.
- Showcase the server app's crontab generated with the 'whenever' gem.
- Ability to invoke server-specific rake tasks.

🔔 **Notification Integrations:**

- Set up notifications through Slack or generic Webhooks.
- Customize notification levels (info/error).

⚙️ **Backup Settings Customization:**

- Define the number of backups retained, both locally and externally.
- Toggle backup tasks and external backups.
- S3 integration for backup storage, including customization of bucket, region, and endpoint details.

📅 **Schedule Tasks:**

- Couple with the 'whenever' gem to schedule daily backup creation and old backup removal.

🔗 **Slack & Webhook Integrations:**

- Integrate seamlessly with Slack or use webhooks for notifications, alerting you on essential operations or any potential issues.

☁️ **Backup Providers:**

- S3 and other S3-compatible services are supported to ensure your data remains secure and accessible.

[↑](#)

## Requirements

```ruby
'capistrano', '~> 3.0'
'whenever' # for scheduling tasks
'figaro' # for environment variables if you use figaro_yml tasks

# hint: if you use other aws-sdk gems, its possible that you have to update them too
```

[↑](#)

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

or if you want to use only specific tasks one or more of the following:

```ruby
# Capfile


require 'capistrano/ops/backup' # backup:database:create, backup:database:pull, backup:storage:create, backup:storage:pull
require 'capistrano/ops/figaro_yml' # figaro_yml:compare, figaro_yml:get, figaro_yml:setup, figaro_yml:backup, figaro_yml:rollback
require 'capistrano/ops/invoke' # invoke:rake
require 'capistrano/ops/logrotate' # logrotate:enable, logrotate:disable, logrotate:check
require 'capistrano/ops/logs' # logs:rails, logs:sidekiq, logs:sidekiq:info, logs:sidekiq:error
require 'capistrano/ops/whenever' # whenever:show_crontab

# optionally and not included in require 'capistrano/ops'
require 'capistrano/ops/wkhtmltopdf' # setup wkhtmltopdf-binary on server
```

and `initializers`

```ruby
# initializers/capistrano_ops.rb

# needed for the backup tasks
require 'capistrano/ops'
```

[↑](#)

## Script overview

| Script                                           | Description                                                              |
| ------------------------------------------------ | ------------------------------------------------------------------------ |
| `cap <environment> backup:create`                | creates backup of postgres database on the server (removed since v1.0.0) |
| `cap <environment> backup:pull`                  | download latest postgres backup from server (removed since v1.0.0)       |
| `cap <environment> backup:database:create`       | creates backup of postgres database on the server                        |
| `cap <environment> backup:database:pull`         | download latest postgres backup from server                              |
| `cap <environment> backup:storage:create`        | creates backup of storage on the server                                  |
| `cap <environment> backup:storage:pull`          | download latest storage backup from server                               |
| `cap <environment> figaro_yml:setup`             | copy local application.yml to server application.yml                     |
| `cap <environment> figaro_yml:compare`           | compare local application.yml with server application.yml                |
| `cap <environment> figaro_yml:get`               | shows env vars from server application.yml configured thru figaro        |
| `cap <environment> figaro_yml:backup`            | creates backup of server application.yml (keeps last 5 versions)         |
| `cap <environment> figaro_yml:rollback`          | rollback server application.yml to previous version                      |
| `cap <environment> logs:rails`                   | display server log live                                                  |
| `cap <environment> logs:sidekiq`                 | display sidekiq log live                                                 |
| `cap <environment> logs:sidekiq:info`            | display sidekiq info log live                                            |
| `cap <environment> logs:sidekiq:error`           | display sidekiq error log live                                           |
| `cap <environment> whenever:show_crontab`        | display server app crontab generated with whenever                       |
| `cap <environment> invoke:rake TASK=<your:task>` | invoke rake task on server                                               |
| `cap <environment> logrotate:enable`             | enable logrotate for logfiles on server                                  |
| `cap <environment> logrotate:disable`            | disable logrotate for logfiles on server                                 |
| `cap <environment> logrotate:check`              | show logrotate status for logfiles on server                             |
| `rake pg:dump`                                   | creates postgres database backup                                         |
| `rake pg:remove_old_dumps`                       | remove old postgres backups                                              |
| `rake storage:backup`                            | creates backup of storage                                                |
| `rake storage:remove_old_backups`                | remove old storage backups                                               |

[↑](#)

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

[↑](#)

### Optional Settings for backup task

| env                        | description                                                                                         |                            type/options                            |
| -------------------------- | --------------------------------------------------------------------------------------------------- | :----------------------------------------------------------------: |
| NUMBER_OF_BACKUPS          | number of backups to keep (default: 7)                                                              |                              `number`                              |
| NUMBER_OF_LOCAL_BACKUPS    | number of backups to keep locally (default: nil)                                                    |                              `number`                              |
| NUMBER_OF_EXTERNAL_BACKUPS | number of backups to keep externally (default: nil)                                                 |                              `number`                              |
| BACKUPS_ENABLED            | enable/disable backup task (default: Rails.env == 'production')                                     |                             `boolean`                              |
| EXTERNAL_BACKUP_ENABLED    | enable/disable external backup (default: false) (only if 'BACKUPS_ENABLED', needs additional setup) |                             `boolean`                              |
| KEEP_LOCAL_STORAGE_BACKUPS | keep local storage backups (default: true)                                                          |                             `boolean`                              |
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

[↑](#)

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

[↑](#)

## Configuration

You can optionally specify the capistrano roles for the rake task (Defaults to `:app`):

```ruby
# Defaults to [:app]
set :rake_roles, %i[db app]
```

[↑](#)

## Slack integration

if you want to use slack integration you have to add this to your `application.yml`

```ruby
NOTIFICATION_TYPE: 'slack'
SLACK_SECRET: '<your-slack-secret>'
SLACK_CHANNEL: '<your-slack-channel>'
```

[↑](#)

## Webhook integration

if you want to use webhook integration you have to add this to your `application.yml`

```ruby
NOTIFICATION_TYPE: 'webhook'
WEBHOOK_URL: '<your-webhook-url>'
WEBHOOK_SECRET: '<your-webhook-secret>'
```

[↑](#)

## Notification level

if you want to use notification level you have to add this to your `application.yml`

```ruby
NOTIFICATION_LEVEL: 'info' # default is 'error'
```

[↑](#)

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

[↑](#)

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

[↑](#)

## Logrotate

Logrotate is a utility designed for administrators who manage servers producing a high volume of log files to help them save some disk space as well as to avoid a potential risk making a system unresponsive due to the lack of disk space.

The capistrano-ops gem provides a set of tasks to manage logrotate on your server:

- `cap <environment> logrotate:enable` - This task enables logrotate for logfiles on the server.
- `cap <environment> logrotate:disable` - This task disables logrotate for logfiles on the server.
- `cap <environment> logrotate:check` - This task shows the logrotate status for logfiles on the server.
  [↑](#)

### Configuration

You can optionally specify the logrotate configuration file path (Defaults to `/etc/logrotate.conf`):

```ruby
# Defaults to '/etc/logrotate.conf'
set :logrotate_path, '/path/to/your/logrotate.conf'
```

[↑](#)

### Usage

To use logrotate, you need to have it installed on your server. If it's not installed, you can install it using the package manager of your system. For example, on Ubuntu, you can install it using apt:

```bash
sudo apt-get install logrotate
```

Once logrotate is installed, you can use the capistrano-ops tasks to manage it.
[↑](#)

## Wkhtmltopdf Setup

This script is used to setup `wkhtmltopdf-binary` in your deployment environment. It is designed to work with Capistrano.

The main task `setup` is hooked to run after the `deploy:symlink:release` task.
It performs the following operations:

- unzip the necessary binary file

- set the binary file permissions

The script assumes, that you have a intializer file for `wicked_pdf` gem, which sets the path to the binary file.
for example:

```ruby
# config/initializers/wicked_pdf.rb
WickedPdf.config = {
  exe_path: "#{Bundler.bundle_path}/gems/wkhtmltopdf-binary-0.12.6.6/bin/wkhtmltopdf_ubuntu_18.04_amd64",
}
```

To use this script, include it in your Capistrano tasks and it will automatically run during deployment.

```ruby
# Capfile
require 'capistrano/ops/wkhtmltopdf'
```

[↑](#)

## Contributing

1. Fork it ( https://github.com/zauberware/capistrano-ops/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

[↑](#)

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

This gem contains code/snippets from the following sources:

- [capistrano-figaro-yml](https://github.com/ChouAndy/capistrano-figaro-yml) by Andy Chou under the [MIT License](https://github.com/chouandy/capistrano-figaro-yml/blob/master/LICENSE.md)
- [capistranorb documentation](https://capistranorb.com/documentation/tasks/rails/)

props to the original authors 🎉
check out their work too!

[↑](#)
