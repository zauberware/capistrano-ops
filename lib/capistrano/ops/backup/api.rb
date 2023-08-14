# frozen_string_literal: true

module Backup
  class Api
    attr_accessor :backup_provider, :provider_config

    def initialize(provider: ENV['BACKUP_PROVIDER'], provider_config: {})
      self.backup_provider = provider
      self.provider_config = provider_config
    end

    def upload(backup_file, filename)
      case backup_provider
      when 's3'
        s3 = Backup::S3.new(**provider_config)
        s3.upload(backup_file, filename)
      when 'scp'
        p 'SCP backup not implemented yet'
      when 'rsync'
        p 'Rsync backup not implemented yet'
      else
        raise Backup::Error, 'Backup provider not configured'
      end
    end

    def remove_old_backups(basename, keep)
      case backup_provider
      when 's3'
        s3 = Backup::S3.new(**provider_config)
        s3.remove_old_backups(basename, keep: keep)
      when 'scp'
        p 'SCP backup not implemented yet'
      when 'rsync'
        p 'Rsync backup not implemented yet'
      else
        raise Backup::Error, 'Backup provider not configured'
      end
    end
  end
end
