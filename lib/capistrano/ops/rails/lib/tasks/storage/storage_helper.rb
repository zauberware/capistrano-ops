# frozen_string_literal: true

module StorageHelper
  def configuration
    @configuration ||=
      {
        backup_path: path_resolver('backups'),
        storage_path: path_resolver('storage'),
        backups_enabled: env_or_production('BACKUPS_ENABLED'),
        external_backup: env_or_production('EXTERNAL_BACKUP_ENABLED'),
        keep_local_backups: env_or_production('KEEP_LOCAL_STORAGE_BACKUPS'),
        backup_provider: ENV['BACKUP_PROVIDER']
      }
  end

  def title
    ENV['DEFAULT_URL'] || "#{Rails.env} Backup"
  end

  def message(result = false, settings = {})
    @backup_path = settings[:backup_path]
    @filename = settings[:filename]
    messages = []
    if result
      messages << "Backup of storage folder successfully finished at #{Time.now}"
      messages << "Backup path:\`#{@backup_path}/#{@filename}\`"
    else
      messages << "Backup of storage folder failed at #{Time.now}"
    end
    messages.join("\n")
  end

  def backup_cmd(settings = {})
    @backup_path = settings[:backup_path]
    @date = Time.now.to_i
    @filename = "storage_#{@date}.tar.gz"
    FileUtils.mkdir_p(@backup_path) unless Dir.exist?(@backup_path)
    "tar -zcf #{@backup_path}/#{@filename} -C #{settings[:storage_path]} ."
  end

  def size_str(size)
    units = %w[B KB MB GB TB]
    e = (Math.log(size) / Math.log(1024)).floor
    s = format('%.2f', size.to_f / 1024**e)
    s.sub(/\.?0*$/, units[e])
  end

  def create_local_backup(filename, storage_path, backup_path)
    FileUtils.mkdir_p(backup_path) unless Dir.exist?(backup_path)
    response = system(backup_cmd(backup_path: backup_path, storage_path: storage_path))
    FileUtils.rm_rf("#{@backup_path}/#{filename}") unless response
    puts response ? "Backup created: #{backup_path}/#{@filename} (#{size_str(File.size("#{@backup_path}/#{@filename}"))})" : 'Backup failed removing dump file'
    response
  end

  private

  def env_or_production(env_var, default: Rails.env.production?)
    if ENV.key?(env_var)
      ENV[env_var] == 'true'
    else
      default
    end
  end

  def path_resolver(folder)
    Rails.root.join(Rails.env.development? ? 'tmp' : '../../shared', folder).to_s
  end
end
