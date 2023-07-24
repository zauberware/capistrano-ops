# frozen_string_literal: true

module Backup
  require 'aws-sdk-s3'
  class S3
    attr_accessor :endpoint, :region, :access_key_id, :secret_access_key, :s3_client

    def initialize(endpoint: ENV['S3_BACKUP_ENDPOINT'], region: ENV['S3_BACKUP_REGION'], access_key_id: ENV['S3_BACKUP_KEY'],
                   secret_access_key: ENV['S3_BACKUP_SECRET'])
      self.endpoint = endpoint
      self.region = region
      self.access_key_id = access_key_id
      self.secret_access_key = secret_access_key
      config = {
        region: region,
        access_key_id: access_key_id,
        secret_access_key: secret_access_key
      }
      config[:endpoint] = endpoint unless endpoint.nil?
      self.s3_client = Aws::S3::Client.new(config)
    end

    def upload(backup_file, key)
      begin
        s3_client.put_object(
          bucket: ENV['S3_BACKUP_BUCKET'],
          key: key,
          body: File.open(backup_file)
        )
      rescue StandardError => e
        puts "Error uploading backup to S3: #{e.message}"
        raise e
      end
      'File uploaded to S3'
    end

    def remove_old_backups(basename, keep: 5)
      bucket = ENV['S3_BACKUP_BUCKET']
      all_items = s3_client.list_objects_v2(bucket: bucket, prefix: basename).contents
      count = all_items.count
      if count <= keep
        p 'Nothing to remove'
        return
      end
      items = all_items.sort_by(&:last_modified).reverse.slice(keep..-1).map(&:key)
      items.each do |item|
        p "Removing #{item} from S3"
        s3_client.delete_object(bucket: bucket, key: item)
      end
    end
  end
end
