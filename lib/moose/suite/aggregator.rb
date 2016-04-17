require_relative "../test_suite"

module Meese
  module Suite
    class Aggregator
      class << self
        def test_suites
          instance.test_suites
        end

        def instance
          @instance ||= new
        end
      end

      def initialize
        run_config
      end

      def test_suites
        # begin
        #
        #   all_group_hash = test_group_list_yml["groups"]
        #   group_hash = {}
        #   if Meese.groups.any?
        #     Meese.groups.each do |group|
        #       if all_group_hash[group]
        #         group_hash[group] = all_group_hash[group]
        #       else
        #         Meese.msg.warn("Specified group '#{group}' is not part of the defined test groups: #{all_group_hash}")
        #       end
        #     end
        #   else
        #     group_hash = all_group_hash
        #   end
        #   group_hash.map do |group_name, attributes|
        #     Meese::TestGroup.new(
        #       name: group_name,
        #       description: attributes,
        #       path: suite_path)
        #   end
        # end

        @test_suites ||= all_suites.map do |builder|
          builder
        end
      end

      def all_suites
        @all_suites ||= Dir.glob(suites_directories).map { |directory|
          TestSuite::Builder.new(directory).build
        }
      end

      def run_config
        Dir.glob(moose_tests_directory + "/*_configuration.rb").map { |config_file|
          load config_file
        }
      end

      def suites_directories
        @suites_directories ||= moose_tests_directory + "/#{config.suite_pattern}"
      end

      def moose_tests_directory
        @moose_tests_directory ||= config.current_directory + "/#{config.moose_tests_directory}"
      end

      def config
        @config ||= Meese.configuration
      end
    end
  end
end
