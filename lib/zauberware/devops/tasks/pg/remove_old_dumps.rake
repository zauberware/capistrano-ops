# frozen_string_literal: true

namespace :pg do
  default_backup_path = Rails.env.development? ? 'tmp/backups' : '../../shared/backups'
  database = Rails.configuration.database_configuration[Rails.env]['database']

  backup_path = Rails.root.join(default_backup_path).to_s
  backups_enabled = Rails.env.production? || ENV['BACKUPS_ENABLED'] == 'true'

  task :remove_old_dumps do
    bash_regex = "'#{database}.{0,}\.dump'"
    total_backups_no = ENV['NUMBER_OF_BACKUPS'] || 1
    # rubocop:disable Layout/LineLength
    cmd = "cd #{backup_path} && ls -lt | grep -E -i #{bash_regex} | tail -n +#{total_backups_no.to_i + 1} | awk '{print $9}'|xargs rm -rf"
    # rubocop:enable Layout/LineLength
    system(cmd) if backups_enabled
    p backups_enabled ? 'Old backups removed' : 'remove_old_dumps: Backups are disabled'
  end
end
