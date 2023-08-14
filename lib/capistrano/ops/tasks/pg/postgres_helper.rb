# frozen_string_literal: true

module PostgresHelper
  def config
    @config ||=
      {
        database: Rails.configuration.database_configuration[Rails.env]['database'],
        username: Rails.configuration.database_configuration[Rails.env]['username'],
        password: Rails.configuration.database_configuration[Rails.env]['password'],
        hostname: Rails.configuration.database_configuration[Rails.env]['host'],
        portnumber: Rails.configuration.database_configuration[Rails.env]['port'],
        backup_path: Rails.root.join(Rails.env.development? ? 'tmp/backups' : '../../shared/backups').to_s,
        backups_enabled: Rails.env.production? || ENV['BACKUPS_ENABLED'] == 'true',
        external_backup: Rails.env.production? || ENV['EXTERNAL_BACKUP_ENABLED'] == 'true'
      }
  end

  def title
    ENV['DEFAULT_URL'] || "#{Rails.env} Backup"
  end

  def content(result, config = {})
    @database = config[:database]
    @backup_path = config[:backup_path]
    @filename = config[:filename]

    messages = []
    if result
      messages << "Backup of #{@database} successfully finished at #{Time.now}"
      messages << "Backup path:\`#{@backup_path}/#{@filename}\`"
    else
      messages << "Backup of #{@database} failed at #{Time.now}"
    end
    messages.join("\n")
  end

  def dump_cmd(config = {})
    @hostname = config[:hostname]
    @database = config[:database]
    @username = config[:username]
    @password = config[:password]
    @portnumber = config[:portnumber]
    @backup_path = config[:backup_path]

    @date = Time.now.to_i
    options = []
    options << " -d #{@database}" if @database.present?
    options << " -U #{@username}" if @username.present?
    options << " -h #{@hostname}" if @hostname.present?
    options << " -p #{@portnumber}" if @portnumber.present?

    @filename = "#{@database}_#{@date}.dump"

    commandlist = []
    commandlist << "export PGPASSWORD='#{@password}'"
    commandlist << "cd #{@backup_path}"
    commandlist << "pg_dump -Fc #{options.join('')} > #{@filename}"
    commandlist.join(' && ')
  end

  def size_str(size)
    units = %w[B KB MB GB TB]
    e = (Math.log(size) / Math.log(1024)).floor
    s = format('%.2f', size.to_f / 1024**e)
    s.sub(/\.?0*$/, units[e])
  end
end
