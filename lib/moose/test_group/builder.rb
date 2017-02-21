module Moose
  module TestGroup
    class Builder < Base
      attr_reader :directory, :test_group, :test_suite, :moose_configuration, :runner

      def initialize(directory:, test_suite:, moose_configuration:, runner:)
        @directory = directory
        @test_suite = test_suite
        @moose_configuration = moose_configuration
        @runner = runner
      end

      def build_list
        Dir.glob(File.join(directory, "*")) { |test_dir|
          collection.add_test_group(test_dir)
        }
        self
      end

      def collection
        @collection ||= Collection.new(
          directory: directory,
          test_suite: test_suite,
          moose_configuration: moose_configuration,
          runner: runner,
        )
      end
    end
  end
end
