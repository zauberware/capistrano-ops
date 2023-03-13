# frozen_string_literal: true

# rubocop:disable Metrics/BlockLength
namespace :pg do
  default_backup_path = Rails.env.development? ? 'tmp/backups' : '../../shared/backups'
  database = Rails.configuration.database_configuration[Rails.env]['database']
  username = Rails.configuration.database_configuration[Rails.env]['username']
  password = Rails.configuration.database_configuration[Rails.env]['password']
  hostname = Rails.configuration.database_configuration[Rails.env]['host']
  portnumber = Rails.configuration.database_configuration[Rails.env]['port']
  backup_path = Rails.root.join(default_backup_path).to_s
  backups_enabled = Rails.env.production? || ENV['BACKUPS_ENABLED'] == 'true'
  
  task :dump do
    api = Notification::Api.new
    date = Time.now.to_i
    user = username.present? ? " -U #{username}" : ''
    host = hostname.present? ? " -h #{hostname}" : ''
    port = portnumber.present? ? " -p #{portnumber}" : ''
    # rubocop:disable Layout/LineLength
    dump_cmd = "export PGPASSWORD='#{password}' && cd #{backup_path} && pg_dump -Fc -d #{database}#{user}#{host}#{port} > #{database}_#{date}.dump"
    # rubocop:enable Layout/LineLength
    if backups_enabled
      system "mkdir -p #{backup_path}" unless Dir.exist?(backup_path)
      result = system(dump_cmd)
      api.send_backup_notification(result, date, database, backup_path)
      # Notification::Slack.new.backup_notification(result, date, database, backup_path)
    end
    if backups_enabled
      # rubocop:disable Layout/LineLength
      p result ? "Backup created: #{backup_path}/#{database}_#{date}.dump" : "Backup failed, created empty file at #{backup_path}/#{database}_#{date}.dump"
      system "rm #{backup_path}/#{database}_#{date}.dump" unless result
    # rubocop:enable Layout/LineLength
    else
      p 'dump: Backups are disabled'
    end
  end
end
# rubocop:enable Metrics/BlockLength
