module Meese
  module Core
    class Runner
      class << self

        def invoke
          ::Meese.run!
        end

        private

        def trap_interrupt
          trap('INT') do
            exit!(1) if Meese.world.wants_to_quit
            Meese.world.wants_to_quit = true
            STDERR.puts "\nExiting... Interrupt again to exit immediately."
          end
        end
      end
    end
  end
end
