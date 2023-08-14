# frozen_string_literal: true

require 'rake'
namespace :storage do
  backup_path = Rails.root.join(Rails.env.development? ? 'tmp/backups' : '../../shared/backups').to_s
  backups_enabled = Rails.env.production? || ENV['BACKUPS_ENABLED'] == 'true'
  external_backup = Rails.env.production? || ENV['EXTERNAL_BACKUP_ENABLED'] == 'true'

  @env_local_no = ENV['NUMBER_OF_LOCAL_BACKUPS'].present? ? ENV['NUMBER_OF_LOCAL_BACKUPS'] : nil
  @env_external_no = ENV['NUMBER_OF_EXTERNAL_BACKUPS'].present? ? ENV['NUMBER_OF_EXTERNAL_BACKUPS'] : nil
  @total_local_backups_no = (@env_local_no || ENV['NUMBER_OF_BACKUPS'] || 7).to_i
  @total_external_backups_no = (@env_external_no || ENV['NUMBER_OF_BACKUPS'] || 7).to_i
  desc 'remove old storage backups'
  task :remove_old_backups do
    bash_regex = "'storage_.{0,}\.tar.gz'"

    unless backups_enabled
      puts 'remove_old_backups: Backups are disabled'
      exit(0)
    end

    unless @total_local_backups_no.positive?
      puts "remove_old_backups: No local cleanup because option '#{if @env_local_no
                                                                     'NUMBER_OF_LOCAL_BACKUPS='
                                                                   else
                                                                     'NUMBER_OF_BACKUPS='
                                                                   end}#{@total_local_backups_no}' sets unlimited backups"
    end

    commandlist = [
      "cd #{backup_path} && ls -lt ",
      "grep -E -i #{bash_regex} ",
      "tail -n +#{@total_local_backups_no + 1} ",
      "awk '{print $9}' ",
      'xargs rm -rf'
    ]

    result = system(commandlist.join(' | ')) if @total_local_backups_no.positive?
    puts 'remove_old_backups: local cleanup finished' if result

    if ENV['BACKUP_PROVIDER'].present? && external_backup
      unless @total_external_backups_no.positive?
        puts "remove_old_backups: No external cleanup because option '#{if @env_external_no
                                                                          'NUMBER_OF_EXTERNAL_BACKUPS='
                                                                        else
                                                                          'NUMBER_OF_BACKUPS='
                                                                        end}#{@total_external_backups_no}' sets unlimited backups"
        exit(0)
      end
      provider = Backup::Api.new
      begin
        result = provider.remove_old_backups('storage_', @total_external_backups_no)
      rescue StandardError => e
        puts "remove_old_backups failed: #{e.message}"
      end
      puts 'remove_old_backups finished' if result
    end
  end
end
