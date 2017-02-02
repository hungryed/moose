module Moose
  module TestGroup
    class Reporter < Base
      attr_reader :test_group

      def initialize(test_group)
        @test_group = test_group
      end

      def summary_report!(opts)
        return unless test_group.has_run
        test_group_name
        message_with("\ttime_elapsed: #{test_group.time_elapsed}:") if test_group.time_elapsed
        TestStatus::POSSIBLE_STATUSES.each do |status|
          status_count = test_group.send("#{status}_tests").count
          if status_count && status_count > 0
            message_with("\t#{status}: #{status_count}")
          end
        end
      end

      def final_report!(opts = {})
        return unless test_group.has_run
        return unless test_group.has_failed_tests?
        test_group_name
        test_group.filtered_test_case_cache.each do |test_case|
          test_case.final_report!(opts)
        end
      end

      def test_group_name
        message_with("#{test_group.name}:")
      end

      def message_with(message, type = :info)
        test_group.msg.send(type, "\t#{message}", true)
      end
    end
  end
end
