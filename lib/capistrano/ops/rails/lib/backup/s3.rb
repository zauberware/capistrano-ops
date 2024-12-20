# frozen_string_literal: true

module Backup
  require 'aws-sdk-s3'
  require 'rubygems/package'
  require 'zlib'
  require 'find'
  require 'capistrano/ops/rails/lib/backup/s3_helper'

  class S3
    include Backup::S3Helper

    attr_accessor :endpoint, :region, :access_key_id, :secret_access_key, :s3_resource, :s3_client

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
      self.s3_client = Aws::S3::Client.new(configuration)
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

    def upload_stream(backup_file, key, type)
      if type == 'folder'
        upload_folder_as_tar_gz_stream(backup_file, key)
      else
        upload_file_as_stream(backup_file, key)
      end
    end

    # rubocop:disable Metrics/MethodLength
    def upload_file_as_stream(file_path, key)
      bucket = ENV['S3_BACKUP_BUCKET']
      # Calculate total size of the file to be uploaded
      total_size = File.size(file_path)
      chunk_size = calculate_chunk_size(total_size)

      uploaded_size = 0

      # Initiate multipart upload

      # Upload the tar.gz data from the file in parts
      part_number = 1
      parts = []
      last_logged_progress = 0
      max_retry_time = 300 # 5 minutes in seconds
      total_wait_time = 0

      begin
        multipart_upload ||= s3_client.create_multipart_upload(bucket: bucket, key: key)
        File.open(file_path, 'rb') do |file|
          while (part = file.read(chunk_size)) # Read calculated chunk size
            retry_count = 0
            begin
              # Initiate multipart upload
              part_upload = s3_client.upload_part(
                bucket: bucket,
                key: key,
                upload_id: multipart_upload.upload_id,
                part_number: part_number,
                body: part
              )
              parts << { part_number: part_number, etag: part_upload.etag }
              uploaded_size += part.size
              part_number += 1

              progress = (uploaded_size.to_f / total_size * 100).round
              if progress >= last_logged_progress + 10
                puts "Upload progress: #{progress}% complete"
                last_logged_progress = progress
              end
            rescue StandardError => e
              retry_count += 1
              wait_time = 2**retry_count
              total_wait_time += wait_time

              if total_wait_time > max_retry_time
                puts "Exceeded maximum retry time of #{max_retry_time / 60} minutes. Aborting upload."
                raise e
              end
              puts "Error uploading part #{part_number}: #{e.message.split("\n").first} (Attempt #{retry_count})"
              puts "Retry in #{wait_time} seconds"
              sleep(wait_time) # Exponential backoff
              puts 'Retrying upload part...'
              retry
            end
          end
        end

        # Complete multipart upload
        s3_client.complete_multipart_upload(
          bucket: bucket,
          key: key,
          upload_id: multipart_upload.upload_id,
          multipart_upload: { parts: parts }
        )
        puts 'Completed multipart upload'
      rescue StandardError => e
        # Abort multipart upload in case of error
        s3_client.abort_multipart_upload(
          bucket: bucket,
          key: key,
          upload_id: multipart_upload.upload_id
        )
        puts "Aborted multipart upload due to error: #{e.message}"
        raise e
      end

      'File uploaded to S3 as tar.gz'
    rescue StandardError => e
      puts "Upload failed: #{e.message}"
      raise e
    end

    def upload_folder_as_tar_gz_stream(folder_path, key)
      bucket = ENV['S3_BACKUP_BUCKET']

      # Calculate total size of the files to be uploaded
      total_size = calculate_total_size(folder_path)
      chunk_size = calculate_chunk_size(total_size)

      # Create a pipe to stream data
      read_io, write_io = IO.pipe
      read_io.binmode
      write_io.binmode

      uploaded_size = 0

      # Start a thread to write the tar.gz data to the pipe
      writer_thread = start_writer_thread(folder_path, write_io)

      # Upload the tar.gz data from the pipe in parts
      part_number = 1
      parts = []
      last_logged_progress = 0
      max_retry_time = 300 # 5 minutes in seconds
      total_wait_time = 0

      begin
        multipart_upload ||= s3_client.create_multipart_upload(bucket: bucket, key: key)
        while (part = read_io.read(chunk_size)) # Read calculated chunk size
          retry_count = 0
          begin
            # Initiate multipart upload
            part_upload = s3_client.upload_part(
              bucket: bucket,
              key: key,
              upload_id: multipart_upload.upload_id,
              part_number: part_number,
              body: part
            )
            parts << { part_number: part_number, etag: part_upload.etag }
            uploaded_size += part.size
            part_number += 1

            progress = (uploaded_size.to_f / total_size * 100).round
            if progress >= last_logged_progress + 10
              puts "Upload progress: #{progress}% complete"
              last_logged_progress = progress
            end
          rescue StandardError => e
            retry_count += 1
            wait_time = 2**retry_count
            total_wait_time += wait_time

            if total_wait_time > max_retry_time
              puts "Exceeded maximum retry time of #{max_retry_time / 60} minutes. Aborting upload."
              raise e
            end
            puts "Error uploading part #{part_number}: #{e.message.split("\n").first} (Attempt #{retry_count})"
            puts "Retry in #{wait_time} seconds"
            sleep(wait_time) # Exponential backoff
            puts 'Retrying upload part...'
            retry
          end
        end

        # Complete multipart upload
        s3_client.complete_multipart_upload(
          bucket: bucket,
          key: key,
          upload_id: multipart_upload.upload_id,
          multipart_upload: { parts: parts }
        )
        puts 'Completed multipart upload'
      rescue StandardError => e
        # Abort multipart upload in case of error
        if multipart_upload
          s3_client.abort_multipart_upload(
            bucket: bucket,
            key: key,
            upload_id: multipart_upload.upload_id
          )
        end
        puts "Aborted multipart upload due to error: #{e.message}"
        raise e
      ensure
        read_io.close unless read_io.closed?
        writer_thread.join
      end

      'Folder uploaded to S3 as tar.gz'
    rescue StandardError => e
      puts "Upload failed: #{e.message}"
      raise e
    end
    # rubocop:enable Metrics/MethodLength

    def start_writer_thread(folder_path, write_io)
      Thread.new do
        parent_folder = File.dirname(folder_path)
        folder_name = File.basename(folder_path)

        Zlib::GzipWriter.wrap(write_io) do |gz|
          Gem::Package::TarWriter.new(gz) do |tar|
            Dir.chdir(parent_folder) do
              Find.find(folder_name) do |file_path|
                if File.directory?(file_path)
                  tar.mkdir(file_path, File.stat(file_path).mode)
                else
                  mode = File.stat(file_path).mode
                  tar.add_file_simple(file_path, mode, File.size(file_path)) do |tar_file|
                    File.open(file_path, 'rb') do |f|
                      while (chunk = f.read(1024 * 1024)) # Read in 1MB chunks
                        tar_file.write(chunk)
                      end
                    end
                  end
                end
              end
            end
          end
        end
      rescue StandardError => e
        puts "Error writing tar.gz data: #{e.message}"
      ensure
        write_io.close unless write_io.closed?
      end
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
