#!/usr/bin/env ruby
# frozen_string_literal: true

# Version management script for Capistrano Ops Gem
# Usage: ruby scripts/bump_version.rb [patch|minor|major]

require 'fileutils'
require_relative '../lib/capistrano/ops/version'

class VersionBumper
  VALID_TYPES = %w[patch minor major].freeze
  VERSION_FILE = 'lib/capistrano/ops/version.rb'
  CHANGELOG_FILE = 'CHANGELOG.md'

  def initialize(bump_type)
    @bump_type = bump_type.to_s.downcase
    @current_version = Capistrano::Ops::VERSION
    validate_bump_type!
  end

  def bump!
    puts "Current version: #{@current_version}"

    new_version = calculate_new_version
    puts "New version: #{new_version}"

    # Update version file
    update_version_file(new_version)

    # Update changelog
    update_changelog(new_version)

    # Create git commit
    create_git_commit(new_version) if git_available?

    puts 'Version bumped successfully!'
    puts ''
    puts '📋 Next steps:'
    puts '1. Review the changes (git diff)'
    puts '2. Fill in CHANGELOG.md with actual changes'
    puts '3. Commit and tag:'
    puts "   git add #{VERSION_FILE} #{CHANGELOG_FILE}"
    puts "   git commit -m 'Release version #{new_version}'"
    puts "   git tag -a v#{new_version} -m 'Release version #{new_version}'"
    puts '4. Push to GitHub:'
    puts "   git push origin main && git push origin v#{new_version}"
    puts '5. Create GitHub Release:'
    puts "   gh release create v#{new_version} --title 'v#{new_version}' \\"
    puts "     --notes-file <(sed -n '/## \\[#{new_version}\\]/,/## \\[/p' CHANGELOG.md | sed '$d')"
    puts ''
    puts '→ GitHub Actions will automatically publish to RubyGems.org! 🚀'
  end

  private

  def validate_bump_type!
    return if VALID_TYPES.include?(@bump_type)

    puts "Error: Invalid bump type '#{@bump_type}'"
    puts "Valid types: #{VALID_TYPES.join(', ')}"
    exit 1
  end

  def calculate_new_version
    parts = @current_version.split('.').map(&:to_i)

    case @bump_type
    when 'patch'
      parts[2] += 1
    when 'minor'
      parts[1] += 1
      parts[2] = 0
    when 'major'
      parts[0] += 1
      parts[1] = 0
      parts[2] = 0
    end

    parts.join('.')
  end

  def update_version_file(new_version)
    puts "Updating #{VERSION_FILE}..."

    content = File.read(VERSION_FILE)
    updated_content = content.gsub(
      /VERSION = ['"][^'"]*['"]/,
      "VERSION = '#{new_version}'"
    )

    File.write(VERSION_FILE, updated_content)
    puts '✓ Version file updated'
  end

  def update_changelog(new_version)
    return unless File.exist?(CHANGELOG_FILE)

    puts "Updating #{CHANGELOG_FILE}..."

    # Read existing changelog
    content = File.read(CHANGELOG_FILE)

    # Find the [Unreleased] section and replace it
    lines = content.lines

    today = Time.now.strftime('%Y-%m-%d')

    # Replace [Unreleased] header with new version
    unreleased_index = lines.find_index { |line| line.start_with?('## [Unreleased]') }

    if unreleased_index
      # Create new version entry
      new_entry = [
        "## [Unreleased]\n",
        "\n",
        "## [#{new_version}] - #{today}\n"
      ]

      # Replace [Unreleased] line
      lines[unreleased_index] = new_entry.join

      # Update comparison links at the bottom
      # Find and update the [Unreleased] link
      unreleased_link_index = lines.rindex { |line| line.start_with?('[Unreleased]:') }
      if unreleased_link_index
        # Update [Unreleased] to compare from new version to HEAD
        lines[unreleased_link_index] = "[Unreleased]: https://github.com/zauberware/capistrano-ops/compare/v#{new_version}...HEAD\n"
        # Add new version link
        lines.insert(unreleased_link_index + 1, "[#{new_version}]: https://github.com/zauberware/capistrano-ops/releases/tag/v#{new_version}\n")
      end
    end

    # Write back to file
    File.write(CHANGELOG_FILE, lines.join)
    puts '✓ Changelog updated (please fill in the release notes under the new version)'
  end

  def git_available?
    system('git --version > /dev/null 2>&1')
  end

  def create_git_commit(new_version)
    puts 'Creating git commit...'

    # Add modified files
    system("git add #{VERSION_FILE}")
    system("git add #{CHANGELOG_FILE}") if File.exist?(CHANGELOG_FILE)

    # Create commit
    commit_message = "Bump version to #{new_version}"
    if system("git commit -m '#{commit_message}'")
      puts "✓ Git commit created: #{commit_message}"
    else
      puts '⚠ Failed to create git commit (you may need to commit manually)'
    end
  end
end

# Main execution
if ARGV.empty?
  puts "Usage: #{$PROGRAM_NAME} [patch|minor|major]"
  puts ''
  puts 'Examples:'
  puts "  #{$PROGRAM_NAME} patch   # 1.0.0 -> 1.0.1"
  puts "  #{$PROGRAM_NAME} minor   # 1.0.0 -> 1.1.0"
  puts "  #{$PROGRAM_NAME} major   # 1.0.0 -> 2.0.0"
  exit 1
end

bump_type = ARGV[0]
bumper = VersionBumper.new(bump_type)
bumper.bump!
