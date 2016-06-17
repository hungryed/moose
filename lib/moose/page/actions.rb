module Moose
  module Page
    module Actions
      include Helpers::Waiter

      # Given an element, set the provided value
      # @param [Watir::Element] locator The element that we want to set a value for
      # @param [String] value The value to set
      def fill_text(locator, value)
        wait_for_element(locator)
        meth = locator.respond_to?(:set) ? :set : :send_keys
        locator.send(meth, value)
      end

      # Given a set of date fields (year, month, day) set to a X number of days ago
      # @param [Hash<String->String>] date_fields Hash with :year, :month & :day
      # @param [Integer] days_ago How many days in the past to set this date?
      # @return [Date] The date X days ago
      def fill_date(date_fields, days_ago)
        past_day = Date.today - days_ago

        select_year = past_day.strftime("%Y").to_s
        select(date_fields[:year], select_year)

        select_month = past_day.strftime("%B").to_s
        select(date_fields[:month], select_month)

        select_day = past_day.strftime("#{past_day.day}").to_s
        select(date_fields[:day], select_day)

        past_day
      end

      # Given a Watir::Element ensure that it is present and click on it
      # @param [Watir::Element] element The element to click_on
      # @return [Boolean] true when successful
      def click_on(element)
        wait_for_element(element)
        wait_until do
          element.click
        end
        true
      end

      # Given a locator, click on it and then wait till it disappears
      # @param [Watir::Element] locator The element to click and then wait on
      def click_and_wait(locator)
        click_on(locator)
        wait_while_present(locator)
      end

      # Given a locator, select the provided value
      # @param [Watir::Element] locator The element to select from
      # @param [String] value The value to select
      def select(locator, value)
        locator.select(value)
        # Return the value to show which was selected in cases where it's not
        # clear (ie: select_random or select_last)
        value
      end

      # Given a tab, select it
      # @param [Watir::Element] tab The tab to select
      def select_tab(tab)
        wait_until do
          tab.select!
          tab.selected?
        end
      end

      # Discover the available options in a select element
      # @param [Watir::Element] locator The select that we are examining
      # @param [Boolean] include_blank Should we include the zeroth option in the select?
      # @param [Array<String>] The available selection entries
      def options_for_select(locator, include_blank = false)
        range = include_blank ? (1..-1) : (0..-1)

        wait_until { locator.present? }
        if locator.options.length > 0
          locator.options.map(&:text)[range]
        else
          jq_cmd = "return $('#{locator.css}').map(function(i, el) { return $(el).text();});"
          browser.execute_script(jq_cmd)[range]
        end
      end

      # Choose randomly in a provided select element
      # @param [Watir::Element] locator The select element to choose from
      def select_random(locator)
        select(locator, options_for_select(locator).sample)
      end

      # Choose the last choice in the provided select selement
      # @param [Watir::Element] locator The select element to choose from
      def select_last(locator)
        select(locator, options_for_select(locator).last)
      end

      # Wait until the element is no longer present
      # @param [Watir::Element] locator The locator to check in on
      def wait_while_present(locator)
        wait_until do
          !locator.present?
        end
      end

      # Wait until the element is present
      # @param [Watir::Element] locator The locator to wait for
      def wait_until_present(locator)
        wait_until do
          locator.present?
        end
      end

      # Wait for the provided element to be present and enabled
      # @param [Watir::Element] locator The locator we want to be present and enabled
      # @param [Integer] attempts How many times we should check to see if present and check to see if enabled
      # @return [Boolean] If the element is present and enabled or not
      def wait_for_element(locator)
        wait_until do
          locator.present? && locator_is_enabled?(locator)
        end
      end

      def murder_dialog(opts)
        return nil unless opts == :ok || opts == :cancel
        browser.execute_script("window.confirm = function() {return #{opts.to_s}}")
      end

      def click_modal_element(locator)
        wait_until do
          locator.wd.location.y == locator.wd.location.y && locator_is_enabled?(locator)
        end
        click_on(locator)
      end

      def attach_file(locator, path)
        wait_for_element(locator)
        locator.set(path)
      end

      def locator_is_enabled?(locator)
        locator.respond_to?(:enabled?) ? locator.enabled? : true
      end
    end
  end
end
