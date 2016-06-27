module Moose
  module TestSuite
    class Instance < Base
      attr_accessor :start_time, :end_time
      attr_reader :directory, :locators, :test_group_collection

      def initialize(directory)
        @directory = directory
      end

      def build_dependencies
        Dir.glob(File.join(directory, "*")) { |test_dir|
          if test_dir =~ /locators$/
            build_locators_from(test_dir)
          elsif test_dir =~ /#{test_group_directory_pattern}/
            build_test_groups_from(test_dir)
          elsif test_dir =~ /.*_configuration\.rb/
            configuration.load_file(test_dir)
          end
        }
        self
      end

      def configuration
        @configuration ||= ::Moose::TestSuite::Configuration.new
      end

      def run!(opts = {})
        return self unless test_group_collection
        self.start_time = Time.now
        Moose.msg.banner("Running Test Suite: #{name}") if name
        configuration.suite_hook_collection.call_hooks_with_entity(entity: self) do
          test_group_collection.run!(opts)
        end
        self.end_time = Time.now
        self
      end

      def rerun_failed!(opts = {})
        return self unless test_group_collection
        return self unless has_failed_tests?
        if name
          Moose.msg.newline
          Moose.msg.invert("Rerunning failed tests for #{name}")
          Moose.msg.newline
        end
        configuration.suite_hook_collection.call_hooks_with_entity(entity: self) do
          test_group_collection.rerun_failed!(opts)
        end
        self.end_time = Time.now
        self
      end

      def report!(opts = {})
        Reporter.new(self).report!(opts)
      end

      def name
        @name ||= begin
          reg = /(.*)#{config.suite_pattern.gsub(/\*/, '')}/
          directory_minus_suite_pattern = reg.match(directory)[1]
          File.basename(directory_minus_suite_pattern)
        rescue
          nil
        end
      end

      def base_url
        configuration.base_url
      end

      def filter_from_options!(options)
        test_group_collection.filter_from_options!(options) if test_group_collection
      end

      def has_available_tests?
        test_group_collection.has_available_tests? if test_group_collection
      end

      def metadata
        [:time_elapsed,:start_time,:end_time,:directory,:name].inject({}) do |memo, method|
          begin
            memo.merge!(method => send(method))
            memo
          rescue => e
            # drop error for now
            memo
          end
        end
      end

      def time_elapsed
        return unless end_time && start_time
        end_time - start_time
      end

      def has_failed_tests?
        test_group_collection.has_failed_tests?
      end

      private

      def test_group_directory_pattern
        config.moose_test_group_directory_pattern.gsub('**', '*')
      end

      def build_test_groups_from(directory)
        test_group_builder = TestGroup::Builder.new(directory: directory, test_suite: self)
        @test_group_collection = test_group_builder.build_list.collection
      end

      def build_locators_from(directory)
        builder = Locator::Builder.new(directory)
        @locators = builder.build_list.collection
      end
    end
  end
end
