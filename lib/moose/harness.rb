module Meese
  class Harness
    class << self
      def run_as(current_test:, suite:, opts: {}, &block)
        needs_browser = opts.fetch(:needs_browser, true)
        suite_instance = Meese.instance_for_suite(suite)
        browser = current_test.new_browser(opts, test_suite: suite_instance) if needs_browser
        begin
          response = block.call(browser, suite_instance)
        ensure
          if needs_browser
            current_test.remove_browser(browser)
          end
        end
        response
      end
    end
  end
end
