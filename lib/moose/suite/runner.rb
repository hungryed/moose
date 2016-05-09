require_relative "aggregator"

module Meese
  module Suite
    class Runner
      attr_accessor :start_time, :end_time

      class << self
        def run!(options = {})
          instance.run!(options)
        end

        def require_files!
          instance.test_suites
        end

        def instance
          @instance ||= new
        end
      end

      def instance_for_suite(suite_name)
        test_suites.find { |suite|
          suite.name == suite_name.to_s
        }
      end

      def test_suites
        @test_suites ||= Aggregator.test_suites
      end

      def manage_snapshot_dir
        # if present, move to _prev
        return unless configuration.snapshots
        if File.directory?(snapshot_directory)
          # remove previous _prev
          if File.directory?("#{snapshot_directory}_prev")
            FileUtils.rm_rf("#{snapshot_directory}_prev")
          end
          FileUtils.mv(snapshot_directory, "#{snapshot_directory}_prev", :force => true)
        end
        Dir.mkdir(snapshot_directory)
      end

      def snapshot_directory
        @snapshot_directory ||= File.join(Meese.world.current_directory, configuration.snapshot_directory)
      end

      def run!(opts = {})
        initialize_run
        trim_test_suites_from(opts)
        configuration.run_hook_collection.call_hooks_with_entity(entity: ::Meese) do
          run_tests(opts)
        end
        end_run
        self
      end

    private

      def initialize_run
        Meese.msg.banner("Starting test run")
        manage_snapshot_dir
        self.start_time = Time.now
        self.end_time = nil
      end

      def end_run
        self.end_time = Time.now
        Meese.msg.newline
        Meese.msg.banner("total time: #{time_elapsed}")
      end

      def time_elapsed
        return unless start_time && end_time
        end_time - start_time
      end

      def run_tests(opts)
        trimmed_test_suites.each_with_index do |suite, i|
          Meese.msg.banner("Test Group #{i+1} of #{trimmed_test_suites.count}")
          suite.run!(opts)
          if configuration.rerun_failed
            Meese.msg.newline
            Meese.msg.invert("Rerunning failed tests for #{suite.name}")
            Meese.msg.newline
            suite.rerun_failed!(opts)
          end
          suite.report!
        end
      end

      def trimmed_test_suites
        @trimmed_test_suites ||= []
      end

      def trim_test_suites_from(opts = {})
        test_suites.select { |test_suite|
          test_suite.filter_from_options!(opts)
          trimmed_test_suites << test_suite if test_suite.has_available_tests?
        }
      end

      def configuration
        @configuration ||= Meese.configuration
      end
    end
  end
end
