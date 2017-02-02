module Moose
  module TestSuite
    class Reporter < Base
      attr_reader :test_suite_instance

      def initialize(test_suite_instance)
        @test_suite_instance = test_suite_instance
      end

      def report!(options = {})
        return unless test_suite_instance.has_run
        time_summary_report
        return unless test_group_collection
        test_group_collection.summary_report!
        test_suite_instance.msg.newline("", true)
        test_group_collection.final_report!
      end

      def time_summary_report
        return unless test_suite_instance.has_run
        test_suite_instance.msg.info("#{test_suite_instance.name}:", true)
        test_suite_instance.msg.info("  time: #{test_suite_instance.time_elapsed} seconds", true) if test_suite_instance.time_elapsed
        TestStatus::POSSIBLE_STATUSES.each do |status|
          status_count = test_suite_instance.send("#{status}_tests").count
          if status_count && status_count > 0
            test_suite_instance.msg.info("  #{status}: #{status_count}", true)
          end
        end
        test_suite_instance.msg.newline("", true)
      end

      def test_group_collection
        test_suite_instance.test_group_collection
      end
    end
  end
end
