# frozen_string_literal: true

namespace :storage do
  @backup_path = Rails.root.join(Rails.env.development? ? 'tmp/backups' : '../../shared/backups').to_s
  @storage_path = Rails.root.join(Rails.env.development? ? 'storage' : '../../shared/storage').to_s
  backups_enabled = Rails.env.production? || ENV['BACKUPS_ENABLED'] == 'true'
  external_backup = Rails.env.production? || ENV['EXTERNAL_BACKUP_ENABLED'] == 'true'

  desc 'backup storage'
  task :backup do
    unless backups_enabled
      puts 'storage: Backups are disabled'
      exit(0)
    end
    notification = Notification::Api.new

    date = Time.now.to_i
    @filename = "storage_#{date}.tar.gz"
    FileUtils.mkdir_p(@backup_path) unless Dir.exist?(@backup_path)
    result = system "tar -zcf #{@backup_path}/#{@filename} -C #{@storage_path} ."
    FileUtils.rm_rf("#{@backup_path}/#{filename}") unless result
    puts result ? "Backup created: #{@backup_path}/#{@filename} (#{size_str(File.size("#{@backup_path}/#{@filename}"))})" : 'Backup failed removing dump file'

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
    notification.send_backup_notification(result, title, message(result), { date: date, backup_path: @backup_path, database: 'storage' })
  end

  def title
    ENV['DEFAULT_URL'] || "#{Rails.env} Backup"
  end

  def message(result)
    messages = []
    if result
      messages << "Backup of storage folder successfully finished at #{Time.now}"
      messages << "Backup path:\`#{@backup_path}/#{@filename}\`"
    else
      messages << "Backup of storage folder failed at #{Time.now}"
    end
    messages.join("\n")
  end

  def size_str(size)
    units = %w[B KB MB GB TB]
    e = (Math.log(size) / Math.log(1024)).floor
    s = format('%.2f', size.to_f / 1024**e)
    s.sub(/\.?0*$/, units[e])
  end
end
