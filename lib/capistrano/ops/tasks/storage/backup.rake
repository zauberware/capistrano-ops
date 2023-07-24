
namespace :storage do
    @backup_path = Rails.root.join(Rails.env.development? ? 'tmp/backups' : '../../shared/backups').to_s
    @storage_path = Rails.root.join(Rails.env.development? ? 'storage' : '../../shared/storage').to_s
    backups_enabled = Rails.env.production? || ENV['BACKUPS_ENABLED'] == 'true'
    
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
        
        
        filesize = size_str(File.size("#{@backup_path}/#{@filename}"))
        
        p result ? "Backup created: #{@backup_path}/#{@filename} (#{filesize})" : "Backup failed removing dump file"
        
        if ENV["BACKUP_PROVIDER"].present? && result
            puts "Uploading #{@filename} to #{ENV["BACKUP_PROVIDER"]}..."
            provider = Backup::Api.new
            begin
                provider.upload("#{@backup_path}/#{@filename}", "#{@filename}")
                puts "#{@filename} uploaded to #{ENV["BACKUP_PROVIDER"]}"
            rescue => e
                puts "#{@filename} upload failed: #{e.message}"
            end
        end
        notification.send_backup_notification(result,title,message(result))
        
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
        case size
        when 0..1024
            "#{size} B"
        when 1024..1024*1024
            "#{size/1024} KB"
        when 1024*1024..1024*1024*1024
            "#{size/1024/1024} MB"
        when 1024*1024*1024..1024*1024*1024*1024
            "#{size/1024/1024/1024} GB"
        end
    end
end