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

      def locator_for(set, *names)
        locators.locator_for(set,*names)
      end

      def element_for(set, *names)
        locator = locator_for(set,*names)
        element_type = locator.element_type
        # Watir includes extra methods if you use the more specific classes like TextField
        elem = if element_type && watir_browser.respond_to?(element_type.to_sym)
          watir_browser.send(element_type.to_sym, locator.css_or_xpath_params)
        else
          watir_browser.element(locator.css_or_xpath_params)
        end
        elem
      end

      # Take a screen shot of the browser and save in given directory
      # @param [Watir::Browser] browser Browser to take a screenshot from
      # @param [String] snapshot_dir Directory path to save the screenshot to
      def take_screenshot(name: Time.now.to_s)
        # take a screen shot if the browser is still alive
        return unless watir_browser.exist?
        begin
          file_path = File.join(snapshot_path, "#{name}.png")
          browser.screenshot.save(file_path)
          Meese.msg.info("\tSNAPSHOT TAKEN: #{file_path}\n")
        rescue => e
          Meese.msg.error("\t*** UNABLE TO TAKE SNAPSHOT ***")
          raise
        end
      end

      def method_missing(meth, *args, &block)
        return watir_browser.send(meth, *args, &block) if respond_to_missing?(meth)
        super
      end

    private

      def respond_to_missing?(meth)
        return true if watir_browser.respond_to?(meth)
        super
      end

      def snapshot_path
        @snapshot_path ||= File.join(Meese.world.current_directory, Meese.config.snapshot_directory, test_suite.name)
      end
    end
  end
end
