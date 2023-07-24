# frozen_string_literal: true

namespace :pg do
  @backup_path = Rails.root.join(Rails.env.development? ? 'tmp/backups' : '../../shared/backups').to_s
  @database = Rails.configuration.database_configuration[Rails.env]['database']
  @total_backups_no = (ENV['NUMBER_OF_BACKUPS'] || 7).to_i
  backups_enabled = Rails.env.production? || ENV['BACKUPS_ENABLED'] == 'true'

  task :remove_old_dumps do
    bash_regex = "'#{@database}.{0,}\.dump'"

    unless backups_enabled && @total_backups_no > 0
      p 'remove_old_dumps: Backups are disabled'
      exit(0)
    end

    
    commandlist = [
      "cd #{@backup_path} && ls -lt ",
      "grep -E -i #{bash_regex} ",
      "tail -n +#{@total_backups_no + 1} ",
      "awk '{print $9}' ",
      "xargs rm -rf"
    ]

    system(commandlist.join(' | '))

    if ENV['BACKUP_PROVIDER'].present?
      provider = Backup::Api.new
      begin
        result = provider.remove_old_backups(@database, @total_backups_no)
      rescue StandardError => e
        p "remove_old_dumps failed: #{e.message}"
      end
      p 'remove_old_dumps finished' if result
    end
  end
end
