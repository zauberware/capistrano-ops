# frozen_string_literal: true

# rubocop:disable Metrics/BlockLength
namespace :pg do
  
  @database = Rails.configuration.database_configuration[Rails.env]['database']
  @username = Rails.configuration.database_configuration[Rails.env]['username']
  @password = Rails.configuration.database_configuration[Rails.env]['password']
  @hostname = Rails.configuration.database_configuration[Rails.env]['host']
  @portnumber = Rails.configuration.database_configuration[Rails.env]['port']
  @backup_path = Rails.root.join(Rails.env.development? ? 'tmp/backups' : '../../shared/backups').to_s
  backups_enabled = Rails.env.production? || ENV['BACKUPS_ENABLED'] == 'true'

  task :dump do
    unless backups_enabled
      p 'dump: Backups are disabled'
      exit(0)
    end

    notification = Notification::Api.new
    commandlist = dump_cmd
    
    system "mkdir -p #{@backup_path}" unless Dir.exist?(@backup_path)
      
    result = system(commandlist.join(' && '))
    
    if ENV['BACKUP_PROVIDER'].present? && result
      p "Uploading #{@filename} to #{ENV['BACKUP_PROVIDER']}..."
      provider = Backup::Api.new
      begin
        provider.upload("#{@backup_path}/#{@filename}", "#{@filename}")
        p "#{@filename} uploaded to #{ENV['BACKUP_PROVIDER']}"
      rescue StandardError => e
        p "#{@filename} upload failed: #{e.message}"
      end
    end
    notification.send_backup_notification(result,title,content(result))
    p result ? "Backup created: #{@backup_path}/#{@filename}" : "Backup failed removing dump file"
    system "rm #{@backup_path}/#{@filename}" unless result
    
  end

  def title
    ENV['DEFAULT_URL'] || "#{Rails.env} Backup"
  end

  def content(result)
    messages = []
    if result
      messages << "Backup of #{@database} successfully finished at #{Time.now}"
      messages << "Backup path:\`#{@backup_path}/#{@filename}\`"
    else
      messages << "Backup of #{@database} failed at #{Time.now}"
    end
    messages.join("\n")
  end

  def dump_cmd
    date = Time.now.to_i
    options = []
    options << " -d #{@database}" if @database.present?
    options << " -U #{@username}" if @username.present?
    options << " -h #{@hostname}" if @hostname.present?
    options << " -p #{@portnumber}" if @portnumber.present?
    
    @filename = "#{@database}_#{date}.dump"
    
    commandlist = []
    commandlist << "export PGPASSWORD='#{@password}'"
    commandlist << "cd #{@backup_path}"
    commandlist << "pg_dump -Fc #{options.join('')} > #{@filename}"
  end

end
# rubocop:enable Metrics/BlockLength
