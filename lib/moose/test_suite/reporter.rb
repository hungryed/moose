module Moose
  module TestSuite
    class Reporter < Base
      attr_reader :test_suite_instance

      def initialize(test_suite_instance)
        @test_suite_instance = test_suite_instance
      end

      def report!(options = {})
        time_summary_report
        test_suite_instance.test_group_collection.summary_report!
        Moose.msg.newline("", true)
        test_suite_instance.test_group_collection.final_report!
      end

      def time_summary_report
        Moose.msg.info("#{test_suite_instance.name}:", true)
        Moose.msg.info("  time: #{test_suite_instance.time_elapsed} seconds", true) if test_suite_instance.time_elapsed
        TestStatus::POSSIBLE_STATUSES.each do |status|
          status_count = test_suite_instance.send("#{status}_tests").count
          if status_count && status_count > 0
            Moose.msg.info("  #{status}: #{status_count}", true)
          end
        end
        Moose.msg.newline("", true)
      end
    end
  end
end
