module Moose
  class TestCase
    class Reporter
      attr_reader :test_case

      def initialize(test_case)
        @test_case = test_case
      end

      def final_report!
        return if test_case.passed?
        return unless test_case.has_run
        with_details do
          if test_case.failed?
            failure_script
            rerun_dialog
          end
        end
      end

      def report!
        return unless test_case.has_run
        with_details do
          if test_case.failed?
            failure_script
          elsif test_case.passed?
            passed_script
          end
        end
      end

      def rerun_dialog
        newline
        message_with(:info, "To Rerun")
        rerun_script
      end

      def rerun_script
        message_with(:info, "#{environment_variables} bundle exec moose #{run_environment} #{test_case.trimmed_filepath}")
      end

      def add_strategy(logger)
        raise "Loggers must respond to write" unless logger.respond_to?(:write)
        log_strategies << logger
      end

      private

      def run_environment
        test_case.test_suite_instance.runner.environment
      end

      def log_strategies
        @log_strategies ||= []
      end

      def err
        test_case.exception
      end

      def trimmed_backtrace
        Helpers::BacktraceHelper.new(err.backtrace).filtered_backtrace
      end

      def configuration
        @configuration ||= test_case.moose_configuration
      end

      def environment_variables
        memo = ""
        Array(configuration.environment_variables).uniq.each do |var_name|
          value = ENV[var_name]
          memo += "#{var_name}=#{value} " if value
        end
        memo
      end

      def with_details(&block)
        newline
        message_with(:name, test_case.trimmed_filepath)
        message_with(:info, "time: #{test_case.time_elapsed}")
        newline

        block.call

        newline
      end

      def failure_script
        message_with(:failure, "TEST failed")
        if err
          message_with(:error, err.class)
          message_with(:error, err.message)
          test_case.msg.report_array(:error, trimmed_backtrace, true)
        end
      end

      def passed_script
        message_with(:pass, "TEST Passed!")
      end

      def newline
        write_message(:info, "\n")
      end

      def message_with(type, message)
        write_message(type, "\t#{message}")
      end

      def write_message(type, message)
        msg = test_case.msg.send(type, message, true)
        logger_type = test_case.msg.logger_type_map(type)
        log_strategies.map { |logger| logger.info(msg) }
      end
    end
  end
end
