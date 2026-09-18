# frozen_string_literal: true

require 'securerandom'

module Capistrano
  module Ops
    module Local
      module Helpers
        def scripts_dir
          File.expand_path(fetch(:local_scripts_dir, 'scripts/local'), Dir.pwd)
        end

        def available_scripts
          Dir.glob(File.join(scripts_dir, '*.rb')).map { |f| File.basename(f) }.sort
        end

        def resolve_script(name)
          return nil if name.nil? || name.empty?

          candidates = [name, "#{name}.rb"].map { |n| File.join(scripts_dir, n) }
          candidates.find { |p| File.exist?(p) }
        end

        def print_available_scripts
          scripts = available_scripts
          if scripts.empty?
            puts "  (no scripts found in #{fetch(:local_scripts_dir, 'scripts/local')}/)"
          else
            scripts.each { |s| puts "  • #{s}" }
          end
        end

        def abort_script_not_given(command)
          puts "\n#{color('Usage:', :bold)} cap <stage> local:#{command} SCRIPT=<filename>"
          puts "\n#{color('Available scripts:', :bold)}"
          print_available_scripts
          abort
        end

        def abort_script_not_found(name)
          puts "\n#{color("Script not found: #{name}", :red)}"
          puts "\n#{color('Available scripts:', :bold)}"
          print_available_scripts
          abort
        end

        def confirm_dangerous_stage!(action)
          stage = fetch(:stage).to_s
          dangerous = fetch(:local_dangerous_stages, %w[production])
          return unless dangerous.include?(stage)

          print "\n#{color("⚠  #{action} on #{stage.upcase}. Continue? [y/N] ", :yellow)}"
          abort 'Aborted.' unless $stdin.gets.to_s.strip.casecmp('y').zero?
        end

        def remote_tmp_path(script_path)
          "/tmp/cap_local_#{SecureRandom.hex(6)}_#{File.basename(script_path)}"
        end

        def color(text, style)
          return text unless $stdout.tty?

          code = { bold: '1', red: '31', green: '32', yellow: '33', cyan: '36', dim: '2' }[style]
          return text unless code

          "\e[#{code}m#{text}\e[0m"
        end
      end
    end
  end
end
