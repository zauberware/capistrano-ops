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
    date = Time.now.to_i
    user = username.present? ? " -U #{username}" : ''
    host = hostname.present? ? " -h #{hostname}" : ''
    port = portnumber.present? ? " -p #{portnumber}" : ''
    # rubocop:disable Layout/LineLength
    dump_cmd = "export PGPASSWORD=#{password} && cd #{backup_path} && pg_dump -d #{database}#{user}#{host}#{port} > #{database}_#{date}.dump"
    # rubocop:enable Layout/LineLength
    if backups_enabled
      system "mkdir -p #{backup_path}" unless Dir.exist?(backup_path)
      result = system(dump_cmd)
      slack_notification(result, date, database, backup_path)
    end
    if backups_enabled
      # rubocop:disable Layout/LineLength
      p result ? "Backup created: #{backup_path}/#{database}_#{date}.dump" : "Backup failed, created empty file at #{backup_path}/#{database}_#{date}.dump"
    # rubocop:enable Layout/LineLength
    else
      p 'dump: Backups are disabled'
    end
  end
  # rubocop:disable Metrics/MethodLength
  def slack_notification(result, date, database, backup_path)
    return unless ENV['SLACK_SECRET'].present? && ENV['SLACK_CHANNEL'].present?

    message_one = "Backup of #{database} successfully finished at #{Time.now}"
    message_two = "Backup path:\`#{backup_path}/#{database}_#{date}.dump\`"
    data = {
      channel: ENV['SLACK_CHANNEL'],
      blocks: [
        {
          type: 'header',
          text: {
            type: 'plain_text',
            text: ENV['DEFAULT_URL'] || "#{database} Backup",
            emoji: true
          }
        },
        {
          type: 'section',
          text: {
            type: 'mrkdwn',
            text: result ? "#{message_one}\n#{message_two}" : "Backup of #{database} failed at #{Time.now}"
          }
        }
      ]
    }
    # rubocop:disable Layout/LineLength
    curl = "curl -X POST https://slack.com/api/chat.postMessage -H 'Content-type: application/json; charset=utf-8' --data '#{data.to_json}' -H 'Authorization: Bearer #{ENV['SLACK_SECRET']}'"
    # rubocop:enable Layout/LineLength
    system curl
  end
  # rubocop:enable Metrics/MethodLength
end
# rubocop:enable Metrics/BlockLength
