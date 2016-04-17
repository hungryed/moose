module Meese
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
        cache[directory_key] ||= build_instance_from(directory)
      end

      def run!(opts = {})
        self.start_time = Time.now
        cache.each do |name, test_group|
          # Meese.log.add_to_log("-Test Case Group: #{name} started\n")
          results << test_group.run!(opts)

        end
        self.end_time = Time.now
        suite_time_took = self.end_time - self.start_time
        # Meese.log.add_to_log("-Test Case Group: #{name} completed in #{suite_time_took}\n\n")
      end

      private

      def results
        @results ||= []
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
        Dir.glob(directory + "/*.yml") do |f|
          descriptions.merge!(read_yaml_file(f))
        end
      end

      def cache
        @cache ||= {}
      end
    end
  end
end
