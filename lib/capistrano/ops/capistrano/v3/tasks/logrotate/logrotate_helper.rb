# frozen_string_literal: true

module LogrotateHelper
  # rubocop:disable Naming/MemoizedInstanceVariableName
  def set_config
    info ''
    @shared_path ||= shared_path
    @log_file_path ||= fetch(:log_file_path) || "#{@shared_path}/log"
    @template_config_filename ||= fetch(:logrotate_template_config_file) || 'templates/logrotate.conf.erb'
    @template_schedule_filename ||= fetch(:logrotate_template_schedule_file) || 'templates/schedule.rb.erb'
    @basepath ||= fetch(:logrotate_basepath) || "#{shared_path}/logrotate"
    @config_filename ||= File.basename(@template_config_filename, '.erb')
    @schedule_filename ||= File.basename(@template_schedule_filename, '.erb')
    @config_file_path ||= "#{@basepath}/#{@config_filename}"
    @schedule_file_path ||= "#{@basepath}/#{@schedule_filename}"
    @config_template ||= config_template
    @schedule_template ||= schedule_template
  end
  # rubocop:enable Naming/MemoizedInstanceVariableName

  def config
    {
      template_config_file: fetch(:logrotate_template_config_file) || 'templates/logrotate.conf.erb',
      template_schedule_file: fetch(:logrotate_template_schedule_file) || 'templates/schedule.rb.erb'
    }
  end

  def make_basepath
    puts capture "mkdir -pv #{@basepath}"
  end

  def delete_files
    puts capture "rm -rfv #{@basepath}"
  end

  def config_template
    return nil unless @template_config_filename && File.exist?(File.expand_path(@template_config_filename, __dir__))

    ERB.new(File.read(File.expand_path(@template_config_filename, __dir__))).result(binding)
  end

  def schedule_template
    return nil unless @template_schedule_filename && File.exist?(File.expand_path(@template_schedule_filename, __dir__))

    ERB.new(File.read(File.expand_path(@template_schedule_filename, __dir__))).result(binding)
  end

  def logrotate_enabled
    test("[ -f #{@config_file_path} ]") && test("[ -f #{@schedule_file_path} ]")
  end

  def logrotate_disabled
    !(test("[ -f #{@config_file_path} ]") && test("[ -f #{@schedule_file_path} ]"))
  end

  def whenever(type)
    case type
    when 'clear'
      puts capture :bundle, :exec, :whenever, '--clear-crontab',
                   "-f #{@schedule_file_path} #{fetch(:whenever_identifier)}_logrotate"
    when 'update'
      puts capture :bundle, :exec, :whenever, '--update-crontab', "-f #{@schedule_file_path}",
                   "-i #{fetch(:whenever_identifier)}_logrotate"
    else
      puts 'type not found'
    end
  end
end
