require 'thread'

module Meese
  module TestGroup
    class Instance < Base
      attr_accessor :start_time, :end_time
      attr_reader :directory, :description, :test_suite

      def initialize(directory:, description:, test_suite:)
        @directory = directory
        @description = description
        @test_suite = test_suite
        read_key_words_yamls
      end

      def build
        Dir.glob(directory + "/**/*.rb") do |file|
          if file =~ /_configuration.rb$/
            configuration.load_file(file)
          else
            add_test_case_from(file)
          end
        end
      end

      def run!(opts = {})
        self.start_time = Time.now
        if moose_config.run_in_threads
          run_in_threads(opts)
        else
          run_out_of_threads(opts)
        end
        self.end_time = Time.now
        group_time_took = self.end_time - self.start_time
        # Meese.log.add_to_log("-Test Group: #{name} completed in #{group_time_took}\n\n")
      end

      def configuration
        @configuration ||= Configuration.new
      end

      private

      def run_in_threads(opts = {})
        trim_test_cases_from(opts).each_slice(moose_config.test_thread_count) do |test_case_set|
          threads = []
          test_case_set.each_with_index do |(name, test_case), index|
            threads << Thread.new do
              run_test_case(
                name: name,
                test_case: test_case,
                options: opts
              )
            end
          end
          threads.map(&:join)
        end
      end

      def run_out_of_threads(opts = {})
        trim_test_cases_from(opts).each_with_index do |(name, test_case), index|
          run_test_case(
            name: name,
            test_case: test_case,
            options: opts
          )
        end
      end

      def run_test_case(name:, test_case:, options: {})
        # Meese.log.add_to_log("-Test Case: #{name} started\n")
        ::Meese.run_test_case_with_hooks(
          test_group: self,
          test_case: test_case,
          options: opts
        )
      end

      def trim_test_cases_from(opts = {})
        test_case_cache
      end

      def results
        @results ||= []
      end

      def add_test_case_from(file)
        file_name = file_name_for(file)
        test_case = TestCase.new(
          file: file,
          test_group: self,
          extra_metadata: keywords.fetch("test_cases", {}).fetch(file_name, {})
        )
        test_case.build
        test_case_cache[file_name] = test_case
      end

      def test_case_cache
        @test_case_cache ||= {}
      end

      def keywords
        @keywords ||= {}
      end

      def read_key_words_yamls
        Dir.glob(directory + "/*.yml") do |f|
          keywords.merge!(read_yaml_file(f))
        end
      end
    end
  end
end
