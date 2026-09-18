# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [1.1.0] - 2026-09-18

### Added

- Add CI workflow (`.github/workflows/ci.yml`) with a Ruby matrix (3.2, 3.3, 3.4) running RSpec, plus separate RuboCop and bundler-audit jobs
- Add Dependabot config for weekly `bundler` and `github-actions` updates
- Add `bundler-audit` dev-dependency and Rake task
- Add minimal spec harness (`spec/spec_helper.rb`, `.rspec`, version smoke spec)
- Add `.rubocop_todo.yml` baseline for new cops that would require API-shape changes (metrics, predicate naming, keyword args)

### Changed

- Widen `required_ruby_version` to `>= 3.2` (previously `>= 3.1.4, < 3.4.0` — blocked Ruby 3.4/3.5)
- Add version bounds for `rails` (`>= 7.2, < 9`), `faraday` (`>= 2.0, < 3.0`) and `nokogiri` (`>= 1.15`)
- Bump `.ruby-version` to `3.4.10`; release workflow now reads it via `ruby-version-file`
- Bump `.rubocop.yml` `TargetRubyVersion` to `3.2` and enable `Gemspec/RequireMFA`
- Bump dev-dependencies: `bundler >= 2.4, < 5`, `rubocop ~> 1.80`, `rubocop-rake ~> 0.7`, `rubocop-rspec ~> 3.0`
- `rake` default now runs `spec` + `rubocop`

### Removed

- Remove obsolete `.travis.yml` (Travis CI is end-of-life)
- Remove stray `release.gem` build artifact from repo root
- Remove dead `lib/capistrano/ops/capistrano/v3/tasks/backup.rake`: never wired into `TaskLoader`, required a non-existent `backup_helper` file, and its deprecated tasks (`backup:create` / `backup:pull`) had been superseded by `backup:database:*`

### Fixed

- Fix `NameError` in `Notification::Webhook#backup_notification` when notification level was `error` on a successful backup (`_notification_level` param was referenced without the underscore)
- Fix `bin/console`: required non-existent `capistrano/rake`; now requires `capistrano/ops`
- Correct copy-paste header in `.rubocop.yml` (was labeled for `ms-graph-mailer`)

### Docs

- Clarify optional runtime dependencies (`whenever`, `figaro`, `wicked_pdf`) in README; state Ruby and Rails floors explicitly

## [1.0.11] - 2025-12-22

### Added

- Add GitHub Actions workflow for automated gem releases to RubyGems.org
- Add comprehensive CHANGELOG.md with complete version history
- Add version bump script (bump_version.rb) for automated version management
- Add RuboCop configuration for code style enforcement

### Changed

- Update aws-sdk-s3 dependency to ~> 1.208
- Update Ruby version requirements to >= 3.1.4, < 3.4.0

## [v1.0.10] - 2025-03-04

### Changed

- Update required Ruby version to < 3.4.0

## [v1.0.9] - 2024-12-20

### Fixed

- Fix missing variables in S3 multipart upload
- Update chunk size calculation for S3 uploads

## [v1.0.8] - 2024-12-16

### Fixed

- Add retry logic to S3 uploads for improved reliability

## [v1.0.7] - 2024-12-05

### Fixed

- Minor version bump with typo fixes

## [v1.0.6] - 2024-12-04

### Fixed

- Fix inheritable_copy error

## [v1.0.5] - 2024-12-04

### Fixed

- Update S3 upload to allow streaming directly into tar.gz file

## [v1.0.4] - 2024-08-14

### Fixed

- Update configs helper to retain other stages locally when working with figaro_yml

## [v1.0.3] - 2024-07-15

### Added

- Enhance gem presence check with regex for better Gemfile validation

## [v1.0.2] - 2024-07-15

### Fixed

- Fix wkhtmltopdf broken functionality

## [v1.0.1] - 2024-07-15

### Fixed

- Fix wkhtmltopdf broken functionality (additional fixes)

## [v1.0.0] - 2024-07-11

### Changed

- Major version release - Prepare for v1 release
- Stable API and feature set

## [v0.2.14] - 2024-06-29

### Changed

- Cleanup figaro_yml tasks

## [v0.2.13] - 2024-06-12

### Added

- Add wkhtmltopdf support
- Add loader file for wkhtmltopdf Capistrano task
- Add wkhtmltopdf setup and permission checks for deployment tasks

## [v0.2.12] - 2024-06-10

### Added

- Implement comprehensive logrotate functionality

## [v0.2.11] - 2024-04-16

### Fixed

- Fix logical issue with KEEP_LOCAL_STORAGE_BACKUPS environment variable

## [v0.2.10] - 2024-04-15

### Added

- Add ENV option to remove local storage backups if external backups enabled
- Update README with new configuration options

## [v0.2.9] - 2024-01-15

### Added

- Add backup thinning functionality to manage backup retention

## [v0.2.8] - 2023-09-07

### Changed

- Update required Ruby version

## [v0.2.7] - 2023-08-31

### Fixed

- Fix missing download functionality in backup

## [v0.2.6] - 2023-08-25

### Fixed

- Fix configuration error

## [v0.2.5] - 2023-08-14

### Changed

- Optimize backups functionality

## [v0.2.4] - 2023-08-13

### Changed

- Update README documentation
- Add Faraday for HTTP requests
- Add/split Capistrano backup tasks
- Add deprecation warnings

### Added

- Add .rubocop.yml for code style enforcement

## [v0.2.3] - 2023-07-24

### Added

- Add external backup provider support
- Add S3 object storage provider
- Update notification service

### Changed

- Major refactoring of backup system

### Known Issues

- Webhook notification service temporarily broken

## [v0.2.2] - 2023-07-08

### Changed

- Let bundler choose versions for better dependency management
- Only notify if update fails

### Fixed

- Resolve dependency conflicts for Rails 7 compatibility

## [v0.1.5] - 2023-03-15

### Fixed

- Set dependencies by ruby_version

## [v0.1.4] - 2023-03-13

### Changed

- Optimize database dumps

## [v0.1.3] - 2023-03-08

### Fixed

- Fix bad class declaration in Railtie

## [v0.1.2] - 2023-03-06

### Added

- Add functionality to get application.yml from server

### Changed

- Update README documentation

## [v0.1.1] - 2023-03-06

### Added

- Add get application yaml functionality

## [v0.1.0] - 2023-03-06

### Changed

- Rename gem to capistrano-ops
- Major version bump for initial stable release

## [v0.0.7] - 2022-12-14

### Added

- Add task to run rake task on server

### Changed

- Update readme and refactor backup.rake

## [v0.0.6] - 2022-12-08

### Fixed

- Fix figaro_yml compare functionality

## [v0.0.5] - 2022-12-07

### Fixed

- Fix issue with stdin handling

## [v0.0.4] - 2022-12-07

### Fixed

- Fix issue with stdin handling (additional fixes)

## [v0.0.3] - 2022-12-07

### Fixed

- Fix PGPASSWORD export

## Initial Release - 2022-12-07

### Added

- Initial commit with core functionality
- Database backup capabilities
- Figaro YAML management
- Basic Capistrano integration

[Unreleased]: https://github.com/zauberware/capistrano-ops/compare/v1.1.0...HEAD
[1.1.0]: https://github.com/zauberware/capistrano-ops/releases/tag/v1.1.0
[1.0.11]: https://github.com/zauberware/capistrano-ops/releases/tag/v1.0.11
[v1.0.10]: https://github.com/zauberware/capistrano-ops/compare/v1.0.9...v1.0.10
[v1.0.9]: https://github.com/zauberware/capistrano-ops/compare/v1.0.8...v1.0.9
[v1.0.8]: https://github.com/zauberware/capistrano-ops/compare/v1.0.7...v1.0.8
[v1.0.7]: https://github.com/zauberware/capistrano-ops/compare/v1.0.6...v1.0.7
[v1.0.6]: https://github.com/zauberware/capistrano-ops/compare/v1.0.5...v1.0.6
[v1.0.5]: https://github.com/zauberware/capistrano-ops/compare/v1.0.4...v1.0.5
[v1.0.4]: https://github.com/zauberware/capistrano-ops/compare/v1.0.3...v1.0.4
[v1.0.3]: https://github.com/zauberware/capistrano-ops/compare/v1.0.2...v1.0.3
[v1.0.2]: https://github.com/zauberware/capistrano-ops/compare/v1.0.1...v1.0.2
[v1.0.1]: https://github.com/zauberware/capistrano-ops/compare/v1.0.0...v1.0.1
[v1.0.0]: https://github.com/zauberware/capistrano-ops/compare/v0.2.14...v1.0.0
[v0.2.14]: https://github.com/zauberware/capistrano-ops/compare/v0.2.13...v0.2.14
[v0.2.13]: https://github.com/zauberware/capistrano-ops/compare/v0.2.12...v0.2.13
[v0.2.12]: https://github.com/zauberware/capistrano-ops/compare/v0.2.11...v0.2.12
[v0.2.11]: https://github.com/zauberware/capistrano-ops/compare/v0.2.10...v0.2.11
[v0.2.10]: https://github.com/zauberware/capistrano-ops/compare/v0.2.9...v0.2.10
[v0.2.9]: https://github.com/zauberware/capistrano-ops/compare/v0.2.8...v0.2.9
[v0.2.8]: https://github.com/zauberware/capistrano-ops/compare/v0.2.7...v0.2.8
[v0.2.7]: https://github.com/zauberware/capistrano-ops/compare/v0.2.6...v0.2.7
[v0.2.6]: https://github.com/zauberware/capistrano-ops/compare/v0.2.5...v0.2.6
[v0.2.5]: https://github.com/zauberware/capistrano-ops/compare/v0.2.4...v0.2.5
[v0.2.4]: https://github.com/zauberware/capistrano-ops/compare/v0.2.3...v0.2.4
[v0.2.3]: https://github.com/zauberware/capistrano-ops/compare/v0.2.2...v0.2.3
[v0.2.2]: https://github.com/zauberware/capistrano-ops/compare/v0.1.5...v0.2.2
[v0.1.5]: https://github.com/zauberware/capistrano-ops/compare/v0.1.4...v0.1.5
[v0.1.4]: https://github.com/zauberware/capistrano-ops/compare/v0.1.3...v0.1.4
[v0.1.3]: https://github.com/zauberware/capistrano-ops/compare/v0.1.2...v0.1.3
[v0.1.2]: https://github.com/zauberware/capistrano-ops/compare/v0.1.1...v0.1.2
[v0.1.1]: https://github.com/zauberware/capistrano-ops/compare/v0.1.0...v0.1.1
[v0.1.0]: https://github.com/zauberware/capistrano-ops/compare/v0.0.7...v0.1.0
[v0.0.7]: https://github.com/zauberware/capistrano-ops/releases/tag/v0.0.7
