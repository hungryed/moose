module Moose
  module TestSuite
    class Builder < Base
      attr_reader :directory, :configuration

      def initialize(directory, configuration)
        @directory = directory
        @configuration = configuration
      end

      def build
        test_suite_instance = Instance.new(directory, configuration)
        test_suite_instance.build_dependencies
        test_suite_instance
      end
    end
  end
end
