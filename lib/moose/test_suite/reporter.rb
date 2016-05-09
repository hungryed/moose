module Meese
  module TestSuite
    class Reporter < Base
      attr_reader :test_suite_instance

      def initialize(test_suite_instance)
        @test_suite_instance = test_suite_instance
      end

      def report!(options = {})
        Meese.msg.info("#{test_suite_instance.name}:")
        Meese.msg.info("  time: #{time_suite_took} seconds")
        Meese.msg.newline
        test_suite_instance.test_group_collection.report!
      end

      def time_suite_took
        test_suite_instance.end_time - test_suite_instance.start_time
      end
    end
  end
end
