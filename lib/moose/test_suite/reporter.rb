module Moose
  module TestSuite
    class Reporter < Base
      attr_reader :test_suite_instance

      def initialize(test_suite_instance)
        @test_suite_instance = test_suite_instance
      end

      def report!(options = {})
        Moose.msg.info("#{test_suite_instance.name}:", true)
        Moose.msg.info("  time: #{time_suite_took} seconds", true)
        Moose.msg.newline("", true)
        test_suite_instance.test_group_collection.report!
      end

      def time_suite_took
        test_suite_instance.end_time - test_suite_instance.start_time
      end
    end
  end
end
