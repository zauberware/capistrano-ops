# frozen_string_literal: true

require 'rake'
namespace :pg do
  @backup_path = Rails.root.join(Rails.env.development? ? 'tmp/backups' : '../../shared/backups').to_s
  @database = Rails.configuration.database_configuration[Rails.env]['database']
  @env_local_no = ENV['NUMBER_OF_LOCAL_BACKUPS']
  @env_external_no = ENV['NUMBER_OF_EXTERNAL_BACKUPS']
  @total_local_backups_no = (@env_local_no || ENV['NUMBER_OF_BACKUPS'] || 7).to_i
  @total_external_backups_no = (@env_external_no || ENV['NUMBER_OF_BACKUPS'] || 7).to_i
  backups_enabled = Rails.env.production? || ENV['BACKUPS_ENABLED'] == 'true'
  external_backup = Rails.env.production? || ENV['EXTERNAL_BACKUP_ENABLED'] == 'true'

  task :remove_old_dumps do
    bash_regex = "'#{@database}.{0,}\.dump'"

    unless backups_enabled
      puts 'remove_old_dumps: Backups are disabled'
      exit(0)
    end
    unless @total_local_backups_no.positive?
      puts "remove_old_dumps: No local cleanup because option '#{if @env_local_no
                                                                   'NUMBER_OF_LOCAL_BACKUPS='
                                                                 else
                                                                   'NUMBER_OF_BACKUPS='
                                                                 end}#{@total_local_backups_no}' sets unlimited backups"

    end

    commandlist = [
      "cd #{@backup_path} && ls -lt ",
      "grep -E -i #{bash_regex} ",
      "tail -n +#{@total_local_backups_no + 1} ",
      "awk '{print $9}' ",
      'xargs rm -rf'
    ]

    system(commandlist.join(' | '))

    if ENV['BACKUP_PROVIDER'].present? && external_backup
      unless @total_external_backups_no.positive?
        puts "remove_old_dumps: No external cleanup because option '#{if @env_external_no
                                                                        'NUMBER_OF_EXTERNAL_BACKUPS='
                                                                      else
                                                                        'NUMBER_OF_BACKUPS='
                                                                      end}#{@total_external_backups_no}' sets unlimited backups"
        exit(0)
      end
      provider = Backup::Api.new
      begin
        result = provider.remove_old_backups(@database, @total_external_backups_no)
      rescue StandardError => e
        puts "remove_old_dumps failed: #{e.message}"
      end
      puts 'remove_old_dumps finished' if result
    end
  end
end
