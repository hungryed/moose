require_relative "aggregator"

module Meese
  module Suite
    class Runner
      class << self
        def run!
          instance.run!
        end

        def instance
          @instance ||= new
        end
      end

      def results
        @results ||= []
      end

      def instance_for_suite(suite_name)
        test_suites.find { |suite|
          suite.name == suite_name.to_s
        }
      end

      def test_suites
        @test_suites ||= Aggregator.test_suites
      end

      def manage_snapshot_dir
        # if present, move to _prev
        if File.directory?(snapshot_directory)
          # remove previous _prev
          if File.directory?("#{snapshot_directory}_prev")
            FileUtils.rm_rf("#{snapshot_directory}_prev")
          end
          FileUtils.mv(snapshot_directory, "#{snapshot_directory}_prev", :force => true)
        end
        Dir.mkdir(snapshot_directory)
      end

      def snapshot_directory
        @snapshot_directory ||= configuration.current_directory + "/#{configuration.snapshot_directory}"
      end

      def initialize_run
        manage_snapshot_dir
        @start_time = Time.now
        @end_time = nil
        # Meese.log.start_log
        # Meese.log.add_to_log("Browser: #{Meese.chosen_browser}")
        # Meese.log.add_to_log("Base URL: #{@base_url}\n\n")
        # Meese.msg.starting("#{Meese.suite_name} Start")
        test_suites #want to initialize test suites before clearing the save_failure_yml...
        # Meese.log.backup_yml_logs
        # Meese.msg.warn(">==================> copying ./_#{Meese.current_suite.suite_name}_testlog.yml to: _prev_test_testlog.yml!!")
        # Meese.msg.warn(">=======================> clearing ./_#{Meese.current_suite.suite_name}_testlog.yml !!")
      end

      def run!
        initialize_run
        test_suites.each_with_index do |suite, i|
          start_suite_time = Time.now
          # Meese.log.add_to_log("-Test Case Group: #{suite.name} started\n")
          Meese.msg.invert(":Test Group #{i+1} of #{test_suites.count}")
          results << suite.run!({})
          # results += suite.run!(:session_type => session_type, :base_url => base_url, :snapshot_dir => snapshot_directory)

          suite_time_took = Time.now - start_suite_time
          # Meese.log.add_to_log("-Test Case Group: #{suite.name} completed in #{suite_time_took}\n\n")
        end

        # end_test(results)
      end

      def configuration
        @configuration ||= Meese.configuration
      end
    end
  end
end
