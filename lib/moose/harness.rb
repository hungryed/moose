module Moose
  class Harness
    class << self
      def run_as(current_test:, suite:, opts: {}, &block)
        needs_browser = opts.fetch(:needs_browser, true)
        suite_instance = Moose.instance_for_suite(suite)
        browser = current_test.new_browser({test_suite: suite_instance}.merge(opts)) if needs_browser
        begin
          response = block.call(suite_instance, current_test, browser)
        ensure
          current_test.remove_browser(browser) if needs_browser
        end
        response
      end
    end
  end
end
