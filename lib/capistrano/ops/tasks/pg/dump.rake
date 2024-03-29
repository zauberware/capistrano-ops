# frozen_string_literal: true

require_relative './postgres_helper'
namespace :pg do
  include PostgresHelper

  task :dump do
    backup_path = configuration[:backup_path]
    backups_enabled = configuration[:backups_enabled]
    external_backup = configuration[:external_backup]

    unless backups_enabled
      puts 'dump: Backups are disabled'
      exit(0)
    end

    notification = Notification::Api.new
    commandlist = dump_cmd(configuration)

    system "mkdir -p #{backup_path}" unless Dir.exist?(backup_path)

    result = system(commandlist)

    if ENV['BACKUP_PROVIDER'].present? && external_backup && result
      puts "Uploading #{@filename} to #{ENV['BACKUP_PROVIDER']}..."
      provider = Backup::Api.new
      begin
        provider.upload("#{@backup_path}/#{@filename}", @filename.to_s)
        puts "#{@filename} uploaded to #{ENV['BACKUP_PROVIDER']}"
      rescue StandardError => e
        puts "#{@filename} upload failed: #{e.message}"
      end
    end
    notification.send_backup_notification(result, title, content(result, { database: @database, backup_path: @backup_path, filename: @filename }),
                                          { date: @date, backup_path: @backup_path, database: @database })
    puts result ? "Backup created: #{@backup_path}/#{@filename} (#{size_str(File.size("#{@backup_path}/#{@filename}"))})" : 'Backup failed removing dump file'

    system "rm #{@backup_path}/#{@filename}" unless result
  end
end
