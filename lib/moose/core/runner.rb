module Meese
  module Core
    class Runner
      class << self

        def invoke
          ::Meese.run!(configuration_options)
        end

        private

        def configuration_options
          configuration_options_instance.moose_run_args
        end

        def configuration_options_instance
          @configuration_options ||= ConfigurationOptions.new(ARGV)
        end

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
