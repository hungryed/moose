module Moose
  module TestGroup
    class Collection < Base
      attr_accessor :start_time, :end_time
      attr_reader :directory, :test_suite

      def initialize(directory:, test_suite:)
        @directory = directory
        @test_suite = test_suite
        read_description_yaml
      end

      def add_test_group(directory)
        directory_key = key_from_directory(directory)
        cache << build_instance_from(directory)
      end

      def run!(opts = {})
        self.start_time = Time.now
        filtered_cache.each_with_index do |test_group, i|
          test_group.run!(opts)
        end
        self.end_time = Time.now
        self
      end

      def rerun_failed!(opts = {})
        return self unless has_failed_tests?
        filtered_cache.each_with_index do |test_group, i|
          test_group.rerun_failed!(opts)
        end
        self.end_time = Time.now
        self
      end

      def summary_report!(opts = {})
        filtered_cache.each do |test_group|
          test_group.summary_report!(opts)
        end
      end

      def final_report!(opts = {})
        filtered_cache.each do |test_group|
          test_group.final_report!(opts)
        end
      end

      def filter_from_options!(options)
        groups = options.fetch(:groups, {})
        include_groups = groups.fetch(:inclusion_filters, [])
        exclude_groups = groups.fetch(:exclusion_filters, [])

        cache.each do |test_group|
          test_group.filter_from_options!(options)
          next unless test_group

          if exclude_groups.length > 0
            next if exclude_groups.any? { |group_filter|
              test_group.name == group_filter
            }
          end

          if include_groups.length > 0
            next unless include_groups.any? { |group_filter|
              test_group.name == group_filter
            }
          end

          filtered_cache << test_group if test_group.has_available_tests?
        end
      end

      def has_available_tests?
        filtered_cache.size > 0
      end

      TestStatus::POSSIBLE_STATUSES.each do |meth|
        define_method("#{meth}_tests") do
          filtered_cache.map { |test_group|
            test_group.send("#{meth}_tests")
          }.flatten
        end

        define_method("has_#{meth}_tests?") do
          filtered_cache.any? { |test_group|
            test_group.send("has_#{meth}_tests?")
          }
        end
      end

      def tests
        filtered_cache.map { |test_group|
          test_group.filtered_test_case_cache
        }.flatten
      end

      private

      def filtered_cache
        @filtered_cache ||= []
      end

      def build_instance_from(directory)
        directory_key = key_from_directory(directory)
        instance = Instance.new(
          directory: directory,
          description: description_for(directory_key),
          test_suite: test_suite
        )
        instance.build
        instance
      end

      def description_for(directory_key)
        descriptions.fetch("groups", {}).fetch(directory_key, "no description provided")
      end

      def key_from_directory(directory)
        File.basename(directory)
      end

      def descriptions
        @descriptions ||= {}
      end

      def read_description_yaml
        Dir.glob(File.join(directory, "/*.yml")) do |f|
          descriptions.merge!(read_yaml_file(f))
        end
      end

      def cache
        @cache ||= []
      end
    end
  end
end
