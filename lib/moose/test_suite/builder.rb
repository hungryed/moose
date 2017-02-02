module Moose
  module TestSuite
    class Builder < Base
      attr_reader :directory, :configuration, :runner

      def initialize(directory:, configuration:, runner:)
        @directory = directory
        @configuration = configuration
        @runner = runner
      end

      def build
        test_suite_instance = Instance.new(
          directory: directory,
          moose_configuration: configuration,
          runner: runner
        )
        test_suite_instance.build_dependencies
        test_suite_instance
      end
    end
  end
end
