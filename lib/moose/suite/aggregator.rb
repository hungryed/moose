require_relative "../test_suite"

module Moose
  module Suite
    class Aggregator
      attr_reader :configuration, :runner

      def initialize(configuration:, runner:)
        @configuration = configuration
        @runner = runner
        run_config
      end

      def test_suites
        @test_suites ||= all_suites.map do |builder|
          builder
        end
      end

      def all_suites
        @all_suites ||= Dir.glob(suites_directories).map { |directory|
          TestSuite::Builder.new(
            directory: directory,
            configuration: configuration,
            runner: runner
          ).build
        }
      end

      def run_config
        Dir.glob(File.join(moose_tests_directory, "*_configuration.rb")).map { |config_file|
          load config_file
        }
      end

      def suites_directories
        @suites_directories ||= File.join(moose_tests_directory, configuration.suite_pattern)
      end

      def moose_tests_directory
        @moose_tests_directory ||= File.join(Moose.world.current_directory, configuration.moose_tests_directory)
      end
    end
  end
end
