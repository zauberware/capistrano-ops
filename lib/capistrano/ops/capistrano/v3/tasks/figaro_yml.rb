# frozen_string_literal: true

Dir.glob("#{File.expand_path(__dir__)}/figaro_yml/**/*.rake").each { |f| load f }
