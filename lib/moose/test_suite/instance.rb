module Meese
  module TestSuite
    class Instance < Base
      attr_accessor :start_time, :end_time
      attr_reader :directory, :locators, :test_group_collection

      def initialize(directory)
        @directory = directory
      end

      def build_dependencies
        # other_directories_to_require_all = []
        Dir.glob(directory + "/#{config.test_pattern}/*") { |test_dir|
          if test_dir =~ /locators$/
            build_locators_from(test_dir)
          elsif test_dir =~ /#{test_group_directory_pattern}/
            build_test_groups_from(test_dir)
          elsif test_dir =~ /.*_configuration\.rb/
            configuration.load_file(test_dir)
          # else
          #   other_directories_to_require_all << test_dir
          end
        }
        # require_all *other_directories_to_require_all
        self
      end

      def configuration
        @configuration ||= ::Meese::TestSuite::Configuration.new
      end

      def run!(opts = {})
        if test_group_collection
          self.start_time = Time.now
          # Meese.log.add_to_log("-Test Suite: #{name} started\n")
          results << test_group_collection.run!(opts)
          self.end_time = Time.now
          suite_time_took = self.end_time - self.start_time
          # Meese.log.add_to_log("-Test Suite: #{name} completed in #{suite_time_took}\n\n")
        end
        self
      end

      def name
        @name ||= begin
          reg = /(.*)#{config.suite_pattern.gsub(/\*/, '')}/
          directory_minus_suite_pattern = reg.match(directory)[1]
          File.basename(directory_minus_suite_pattern)
        end
      end

      def base_url
        configuration.base_url
      end

      private

      def results
        @results ||= []
      end

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
