module Meese
  module Browser
    class Instance
      attr_reader :test_suite, :browser_options

      def initialize(test_suite:, browser_options: {})
        @test_suite = test_suite
        @browser_options = browser_options
        @closed = false
        watir_browser
      end

      def watir_browser
        @watir_browser ||= Handler.new_browser(browser_options)
      end

      def close!
        unless @closed
          Meese::Browser::Handler.close_browser(watir_browser)
          @closed = true
        end
      end

      def locators
        @locators ||= test_suite.locators
      end

      def locator_set_for(set_name)
        locators.locator_set_for(set_name)
      end

      def locator_for(set, name)
        locators.locator_for(set,name)
      end

      def element_for(set, name)
        locator = locator_for(set,name)
        element_type = locator.element_type
        # Watir includes extra methods if you use the more specific classes like TextField
        elem = if element_type && watir_browser.respond_to?(element_type.to_sym)
           watir_browser.send(element_type.to_sym, locator.css_or_xpath_params)
        else
          watir_browser.element(locator.css_or_xpath_params)
        end
        elem
      end
    end
  end
end
