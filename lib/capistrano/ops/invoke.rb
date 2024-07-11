# frozen_string_literal: true

Dir.glob("#{File.expand_path(__dir__)}/invoke/tasks/**/*.rake").each { |f| load f }
