require_relative "aggregator"

module Moose
  module Suite
    class Runner
      attr_accessor :start_time, :end_time, :configuration, :environment
      class << self
        attr_reader :instance

        def build_instance(configuration:, environment:)
          @instance = new(
            configuration: configuration,
            environment: environment
          )
        end
      end

      def initialize(configuration:, environment:)
        @configuration = configuration
        @environment = environment
      end

      def require_files!
        test_suites
      end

      def base_url_for(suite_name)
        instance_for_suite(suite_name).configuration.base_url
      end

      def instance_for_suite(suite_name)
        test_suites.find { |suite|
          suite.name == suite_name.to_s
        }
      end

      def test_suites
        @test_suites ||= aggregator.test_suites
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
        @snapshot_directory ||= File.join(Moose.world.current_directory, configuration.moose_tests_directory, configuration.snapshot_directory)
      end

      def run!(opts = {})
        initialize_run
        trim_test_suites_from(opts)
        configuration.run_hook_collection.call_hooks_with_entity(entity: self) do
          run_tests(opts)
        end
        persist_failed_tests!
        end_run
        self
      end

      def msg
        @msg ||= Utilities::Message::Delegator.new(configuration)
      end

    private

      def aggregator
        @aggregator ||= Aggregator.new(
          configuration: configuration,
          runner: self
        )
      end

      def initialize_run
        msg.banner("Starting test run")
        manage_snapshot_dir
        self.start_time = Time.now
        self.end_time = nil
      end

      def end_run
        print_summary_information
        self.end_time = Time.now
        msg.newline
        msg.banner("total time: #{time_elapsed}")
      end

      def print_summary_information
        trimmed_test_suites.each(&:time_summary_report)
        failures = failed_tests
        if failures.any?
          msg.info("Failed Tests:")
          failures.each(&:rerun_script)
        end
      end

      def time_elapsed
        return unless start_time && end_time
        end_time - start_time
      end

      def persist_failed_tests!
        Core::TestStatusPersistor.persist!(configuration, tests)
      end

      def failed_tests
        tests.select { |test|
          test.failed?
        }
      end

      def tests
        trimmed_test_suites.each_with_object([]) do |test_suite, memo|
          memo.push(*test_suite.tests)
        end
      end

      def run_tests(opts)
        trimmed_test_suites.each_with_index do |suite, i|
          next if Moose.world.wants_to_quit
          msg.banner("Test Suite #{i+1} of #{trimmed_test_suites.count}")
          suite.run!(opts)
          if configuration.rerun_failed
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
    end
  end
end
