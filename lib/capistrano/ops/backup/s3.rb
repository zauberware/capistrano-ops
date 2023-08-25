# frozen_string_literal: true

module Backup
  require 'aws-sdk-s3'
  class S3
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
        secret_access_key: secret_access_key
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

      count = all_items.count

      if count <= keep
        puts 'Nothing to remove'
        exit(0)
      end

      delete_items = all_items.slice(keep..-1)

      delete_items.each do |item_obj|
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
