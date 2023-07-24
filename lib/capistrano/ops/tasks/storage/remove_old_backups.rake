# frozen_string_literal: true

require 'rake'
namespace :storage do
  backup_path = Rails.root.join(Rails.env.development? ? 'tmp/backups' : '../../shared/backups').to_s
  backups_enabled = Rails.env.production? || ENV['BACKUPS_ENABLED'] == 'true'
  @total_backups_no = (ENV['NUMBER_OF_BACKUPS'] || 7).to_i

  desc 'remove old storage backups'
  task :remove_old_backups do
    bash_regex = "'storage_.{0,}\.tar.gz'"

    unless backups_enabled && @total_backups_no.positive?
      p 'remove_old_backups: Backups are disabled'
      exit(0)
    end

    commandlist = [
      "cd #{backup_path} && ls -lt ",
      "grep -E -i #{bash_regex} ",
      "tail -n +#{@total_backups_no + 1} ",
      "awk '{print $9}' ",
      'xargs rm -rf'
    ]

    system(commandlist.join(' | '))

    if ENV['BACKUP_PROVIDER'].present?
      provider = Backup::Api.new
      begin
        result = provider.remove_old_backups('storage_', @total_backups_no)
      rescue StandardError => e
        p "remove_old_backups failed: #{e.message}"
      end
      p 'remove_old_backups finished' if result
    end
  end
end
