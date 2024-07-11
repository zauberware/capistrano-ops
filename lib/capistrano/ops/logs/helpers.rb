# frozen_string_literal: true

module Capistrano
  module Ops
    module Logs
      module Helpers
        def trap_interrupt
          trap('INT') do
            print "\rDisconnecting... Done.\n"
            exit 0
          end
        end
      end
    end
  end
end
