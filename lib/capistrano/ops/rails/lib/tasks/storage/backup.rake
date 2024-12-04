# frozen_string_literal: true

require_relative './storage_helper'
namespace :storage do
  include StorageHelper

  desc 'backup storage'
  task :backup do
    backup_path = configuration[:backup_path]
    storage_path = configuration[:storage_path]
    backups_enabled = configuration[:backups_enabled]
    external_backup = configuration[:external_backup]
    keep_local_backups = configuration[:keep_local_backups]
    backup_provider = configuration[:backup_provider]
    unless backups_enabled
      puts 'storage: Backups are disabled'
      exit(0)
    end
    notification = Notification::Api.new

    response = false
    if keep_local_backups
      puts "Creating backup of storage folder at #{Time.now}"
      response = create_local_backup(@filename, storage_path, backup_path)
    end
    if backup_provider.present? && external_backup
      @date = Time.now.to_i
      @filename = "storage_#{@date}.tar.gz"
      puts "Uploading #{@filename} to #{backup_provider}..."
      provider = Backup::Api.new
      begin
        if keep_local_backups
          provider.upload("#{backup_path}/#{@filename}", @filename.to_s, 'file')
        else
          provider.upload(storage_path, @filename.to_s, 'folder')
          response = true
        end
        puts "#{@filename} uploaded to #{backup_provider}" if response
      rescue StandardError => e
        puts "#{@filename} upload failed: #{e.message}"
        response = false
      end
    end

    notification.send_backup_notification(response, title, message(response, { backup_path: backup_path, filename: @filename }),
                                          { date: @date, backup_path: @backup_path, database: 'storage' })
  end
end
