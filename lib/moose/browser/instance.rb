require 'fileutils'
require_relative "../utilities"

module Moose
  module Browser
    class Instance
      attr_reader :test_suite, :test_case, :browser_options
      include Utilities::Inspectable

      def initialize(test_suite:, test_case: ,browser_options: {})
        @test_suite = test_suite
        @test_case = test_case
        @browser_options = browser_options
        @closed = false
        watir_browser
      end

      def watir_browser
        @watir_browser ||= Handler.new_browser(test_case.moose_configuration, browser_options)
      end

      def close!
        unless @closed
          Moose::Browser::Handler.close_browser(watir_browser)
          @closed = true
        end
      end

      # Take a screen shot of the browser and save in given directory
      # @param [Watir::Browser] browser Browser to take a screenshot from
      # @param [String] snapshot_dir Directory path to save the screenshot to
      def take_screenshot(name: Time.now.to_s)
        # take a screen shot if the browser is still alive
        return unless watir_browser.exist?
        return unless test_case.moose_configuration.snapshots
        begin
          ::FileUtils.mkdir_p(snapshot_path)
          file_path = File.join(snapshot_path, "#{name}")
          browser.screenshot.save(file_path)
          Moose.msg.info("\tSNAPSHOT TAKEN: #{file_path}\n")
          file_path
        rescue => e
          Moose.msg.error("\t*** UNABLE TO TAKE SNAPSHOT ***")
          raise
        end
      end

      def method_missing(meth, *args, &block)
        return watir_browser.send(meth, *args, &block) if respond_to_missing?(meth)
        super
      end

    private

      def respond_to_missing?(meth, include_private = false)
        return true if watir_browser.respond_to?(meth)
        super
      end

      def snapshot_path
        @snapshot_path ||= File.join(
          Moose.suite.snapshot_directory,
          test_suite.name
        )
      end
    end
  end
end
