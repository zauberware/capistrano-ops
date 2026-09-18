# frozen_string_literal: true

require 'spec_helper'
require 'tmpdir'
require 'capistrano/ops/local/helpers'

RSpec.describe Capistrano::Ops::Local::Helpers do
  let(:host) do
    Class.new do
      include Capistrano::Ops::Local::Helpers

      def initialize(scripts_dir_override)
        @scripts_dir_override = scripts_dir_override
      end

      def fetch(key, default = nil)
        return @scripts_dir_override if key == :local_scripts_dir

        default
      end
    end
  end

  around do |example|
    Dir.mktmpdir do |dir|
      @tmp = dir
      Dir.chdir(dir) { example.run }
    end
  end

  def write_script(name)
    dir = File.join(@tmp, 'ops', 'scripts')
    FileUtils.mkdir_p(dir)
    File.write(File.join(dir, name), '# example')
    dir
  end

  describe '#available_scripts' do
    it 'returns sorted basenames of .rb files' do
      write_script('b.rb')
      write_script('a.rb')
      write_script('note.txt')

      instance = host.new('ops/scripts')

      expect(instance.available_scripts).to eq(%w[a.rb b.rb])
    end

    it 'is empty when the directory does not exist' do
      instance = host.new('does/not/exist')

      expect(instance.available_scripts).to eq([])
    end
  end

  describe '#resolve_script' do
    it 'returns the full path when the exact filename exists' do
      write_script('foo.rb')

      instance = host.new('ops/scripts')

      expect(instance.resolve_script('foo.rb')).to end_with('/ops/scripts/foo.rb')
    end

    it 'auto-appends .rb when omitted' do
      write_script('foo.rb')

      instance = host.new('ops/scripts')

      expect(instance.resolve_script('foo')).to end_with('/ops/scripts/foo.rb')
    end

    it 'returns nil for unknown names' do
      write_script('foo.rb')

      instance = host.new('ops/scripts')

      expect(instance.resolve_script('bar')).to be_nil
    end

    it 'returns nil for empty input' do
      instance = host.new('ops/scripts')

      expect(instance.resolve_script(nil)).to be_nil
      expect(instance.resolve_script('')).to be_nil
    end
  end

  describe '#remote_tmp_path' do
    it 'produces a unique /tmp path preserving the basename' do
      instance = host.new('ops/scripts')

      path = instance.remote_tmp_path('/some/where/foo.rb')

      expect(path).to match(%r{\A/tmp/cap_local_[0-9a-f]{12}_foo\.rb\z})
    end
  end

  describe '#color' do
    it 'returns plain text when stdout is not a TTY' do
      instance = host.new('ops/scripts')
      allow($stdout).to receive(:tty?).and_return(false)

      expect(instance.color('hello', :red)).to eq('hello')
    end

    it 'wraps text in ANSI escape when stdout is a TTY and style is known' do
      instance = host.new('ops/scripts')
      allow($stdout).to receive(:tty?).and_return(true)

      expect(instance.color('hello', :red)).to eq("\e[31mhello\e[0m")
    end

    it 'passes text through unchanged for unknown styles' do
      instance = host.new('ops/scripts')
      allow($stdout).to receive(:tty?).and_return(true)

      expect(instance.color('hello', :magenta)).to eq('hello')
    end
  end
end
