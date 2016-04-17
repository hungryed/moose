module Meese
  module TestGroup
    class Builder < Base
      attr_reader :directory, :locator_list, :test_group, :test_suite

      def initialize(directory:, test_suite:)
        @directory = directory
        @test_suite = test_suite
      end

      def build_list
        Dir.glob(directory + "/*") { |test_dir|
          collection.add_test_group(test_dir)
        }
        self
      end

      def collection
        @collection ||= Collection.new(directory: directory, test_suite: test_suite)
      end
    end
  end
end
