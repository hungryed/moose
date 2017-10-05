module Moose
  module Core
    class Runner
      attr_reader :args

      class << self
        def invoke(args = ARGV)
          trap_interrupt
          instance = new(args)
          instance.configure!
          instance.run!
        end

        def trap_interrupt
          return if @already_trapped
          trap('INT') do
            exit!(1) if Moose.world.wants_to_quit
            Moose.world.wants_to_quit = true
            STDERR.puts "\nExiting... Interrupt again to exit immediately."
            begin
              throw(:short_circuit, "skipped")
            rescue ArgumentError => e
              raise e unless e.message =~ /uncaught throw \:short_circuit/
            end
          end
          @already_trapped = true
        end
      end

      def initialize(args)
        @args = args
      end

      def configure!
        configuration_options_instance.parse_args
        runner.require_files!
        ::Moose.pre_run_reset!
        configure_from_options
      end

      def run!
        runner.run!(run_options)
      end

      private

      def runner
        @runner ||= ::Moose::Suite::Runner.build_instance(
          environment: environment,
          configuration: configuration_options_instance.config
        )
      end

      def environment
        configuration_options_instance.environment
      end

      def run_options
        configuration_options_instance.moose_run_args
      end

      def configure_from_options
        configuration_options_instance.configure_from_options
      end

      def configuration_options_instance
        @configuration_options_instance ||= ConfigurationOptions.new(args)
      end
    end
  end
end
