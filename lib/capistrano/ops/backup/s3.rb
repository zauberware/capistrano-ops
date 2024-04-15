# frozen_string_literal: true

module Backup
  require 'aws-sdk-s3'
  require 'capistrano/ops/backup/s3_helper'
  class S3
    include Backup::S3Helper
    attr_accessor :endpoint, :region, :access_key_id, :secret_access_key, :s3_resource

    def initialize(endpoint: ENV['S3_BACKUP_ENDPOINT'], region: ENV['S3_BACKUP_REGION'], access_key_id: ENV['S3_BACKUP_KEY'],
                   secret_access_key: ENV['S3_BACKUP_SECRET'])
      self.endpoint = endpoint
      self.region = region
      self.access_key_id = access_key_id
      self.secret_access_key = secret_access_key
      configuration = {
        region: region,
        access_key_id: access_key_id,
        secret_access_key: secret_access_key,
        force_path_style: true

      }
      configuration[:endpoint] = endpoint unless endpoint.nil?
      self.s3_resource = Aws::S3::Resource.new(configuration)
    end

    def upload(backup_file, key)
      begin
        s3_resource.bucket(ENV['S3_BACKUP_BUCKET']).object(key).upload_file(backup_file)
      rescue Backup::Error => e
        puts "Upload failed: #{e.message}"
        raise e
      end
      'File uploaded to S3'
    end

    def remove_old_backups(basename, keep: 5)
      all_items = s3_resource.bucket(ENV['S3_BACKUP_BUCKET']).objects(prefix: basename).map do |item|
        { key: item.key, last_modified: item.last_modified }
      end

      all_items = all_items.sort_by { |hsh| hsh[:last_modified] }.reverse
      months = get_months(all_items)
      old_months = get_old_months(months)
      if old_months&.empty? || old_months.nil?
        puts 'No old months to remove'
      else
        old_months.each do |month|
          items = get_items_by_month(all_items, month)
          delete_items = get_delete_items(items, 1)
          puts "Removing #{month} from S3"
          delete_items.each do |item_obj|
            puts "Removing #{item_obj[:key]} from S3"
            s3_resource.bucket(ENV['S3_BACKUP_BUCKET']).object(item_obj[:key]).delete
          end
        end
        puts 'Old months removed from S3'
      end
      current_month = get_current_month(all_items)
      current_month_delete_items = get_delete_items(current_month, keep)
      if current_month_delete_items&.empty? || current_month_delete_items.nil?
        puts 'No old backups to remove'
        exit(0)
      end

      current_month_delete_items.each do |item_obj|
        puts "Removing #{item_obj[:key]} from S3"
        s3_resource.bucket(ENV['S3_BACKUP_BUCKET']).object(item_obj[:key]).delete
      end
      puts 'Old backups removed from S3'
    rescue Backup::Error => e
      puts "Remove failed: #{e.message}"
      raise e
    end
  end
end
