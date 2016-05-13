module Meese
  module Page
    class Base
      include Actions

      class << self

        def path(full_path)

        end
      end

      attr_reader :browser

      def initialize(browser:)
        @browser = browser
      end

      def go_to(path)
        browser.goto(path)
        wait_until do
          browser.ready_state == 'complete'
        end
      end

      def element_for(*args)
        browser.element_for(*args)
      end
    end
  end
end
