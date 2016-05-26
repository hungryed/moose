module Moose
  module TestSuite
    class Builder < Base
      attr_reader :directory

      def initialize(directory)
        @directory = directory
      end

      def build
        test_suite_instance = Instance.new(directory)
        test_suite_instance.build_dependencies
        test_suite_instance
      end
    end
  end
end
