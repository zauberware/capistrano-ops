# frozen_string_literal: true

module BackupHelper
  def backup_file_name(type)
    regex = type == 'storage' ? "'.{0,}\.tar.gz'" : "'.{0,}\.dump'"
    @backup_file_name ||= capture "cd #{shared_path}/backups && ls -lt | grep -E -i #{regex} | head -n 1 | awk '{print $9}'"
  end

  def backup_file_size
    @backup_file_size ||= capture "cd #{shared_path}/backups && wc -c #{@backup_file_name} | awk '{print $1}'"
  end

  def download_backup(backup_file, type)
    puts "Downloading #{type} backup"
    download! "#{shared_path}/backups/#{backup_file}" , backup_file
    puts "Download finished\nDeleting temporary backup..."
    cleanup_backup(backup_file, "Download finished\nDeleting temporary backup...")
  end

  def cleanup_backup(backup_file, message)
    puts message
    execute "cd #{shared_path}/backups && rm #{backup_file}"
    puts 'Temporary backup deleted'
  end

  def question(question, default = 'n', &block)
    print "#{question} #{default.downcase == 'n' ? '(y/N)' : '(Y/n)'}: "
    input = $stdin.gets.strip.downcase
    answer = (input.empty? ? default : input).downcase.to_s

    if %w[y n].include?(answer)
      block.call(answer == 'y')
    else
      question(question, default, &block)
    end
  end

  def prepare_env
    @env = "RAILS_ENV=#{fetch(:stage)}"
    @path_cmd = "PATH=$HOME/.rbenv/versions/#{RUBY_VERSION}/bin:$PATH"
    @test_command = "cd #{release_path} && #{@path_cmd} && #{@env}"
  end

  def size_str(size)
    units = %w[B KB MB GB TB]
    e = (Math.log(size) / Math.log(1024)).floor
    s = format('%.2f', size.to_f / 1024**e)
    s.sub(/\.?0*$/, units[e])
  end
end
