require 'watir-webdriver'
require 'headless'

module Moose
  module Browser
    class Handler
      # Create a new browser instance and add to list of known browsers.
      # @param [Hash<Symbol=>String>] options Supported options
      # @option options [String] :browser Type of browser to create (like 'chrome', firefox', etc)
      # @option options [Array] :resolution [0] = width, [1] = height
      #
      # @return [Watir::Browser] The new browser instance created
      class << self
        def new_browser(options = {})
          try = 0
          attempts = 3
          setup_watir
          mutex.synchronize {
            begin
              if Moose.config.headless || options.fetch(:headless, false)
                @headless = Headless.new
                @headless.start
                @browser = chrome_browser
              else
                options = {
                  :resolution => [1280,800],
                  :browser => Moose.config.browser,
                }.merge(options)
                res = options[:resolution]

                if options[:browser].to_s =~ /chrome/
                  @browser = chrome_browser
                else
                  @browser = Watir::Browser.new(options[:browser])
                end
                @browser.window.resize_to(res[0].to_i, res[1].to_i)
              end
            rescue => e
              Moose.msg.error("Unable to create new Watir browser object, will try #{attempts - try} more times")
              try += 1
              if try <= attempts
                retry
              else
                # back up the call stack you go
                raise e
              end
            end
            Moose.msg.info("Created new Watir browser object! pid #{browser_pid(@browser)}")
            @browser
          }
        end

        # Given a browser object shut it down and remove it from the browser list.  Will
        # first attempt to do a browser.close, if that fails it will kill the pid of the
        # selenium driver which should also destroy the browser.
        # @param [Watir::Browser] b The browser to close
        def close_browser b
          begin
            pid = browser_pid(b)
            Moose.msg.info("Closing Watir browser! pid #{pid}")
            if b.exists?
              b.close
            end
          rescue => e
            Moose.msg.error("Unable to close browser using Watir browser.close! - #{e.message}")
            Moose.msg.info("Going to kill pid #{pid}")
            begin
              ::Process.kill('KILL', pid)
            rescue => e
              Moose.msg.error("Unable to kill browser using Process.kill!")
              raise
            else
              Moose.msg.info("Killed browser! pid #{pid}")
            end
          else
            Moose.msg.info("Closed browser! pid #{pid}")
          end
        end

        private

        def mutex
          @mutex ||= Mutex.new
        end

        def setup_watir
          @setup_watir ||= Watir.default_timeout = 180
        end

        # Create a new chrome browser with MAGIC SETTINGS.
        # Setting detach ensures that the browsers are closed with chromedriver,
        # otherwise only the chromedriver process is killed and we are left with
        # orphaned browsers.
        # @return [Watir::Browser] a new browser instance
        def chrome_browser
          driver = Selenium::WebDriver.for :chrome, detach: false
          Watir::Browser.new(driver)
        end

        # Return the pid of the given browser
        # @param [Watir::Browser] Determine the pid of this browser
        # @return [String] The pid in question
        def browser_pid(browser)
          browser.driver.instance_variable_get(:@bridge).instance_variable_get(:@service).instance_variable_get(:@process).pid
        end
      end
    end
  end
end
