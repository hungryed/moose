module Moose
  module Page
    class Section < Base
      attr_reader :element_block, :parent
      class << self
        def locator_group(group_name)
          @group_name = group_name
        end

        def group_name
          raise NoGroupName.new("No group provided for #{self}") unless @group_name
          @group_name
        end
      end

      def initialize(browser:, element_block:, parent:)
        super(browser: browser)
        @parent = parent
        @element_block = element_block
      end

      def element_for(*args)
        locator = browser.locator_for(*args)
        element_type = locator.element_type
        # Watir includes extra methods if you use the more specific classes like TextField
        elem = if element_type && _element.respond_to?(element_type.to_sym)
          _element.send(element_type.to_sym, locator.css_or_xpath_params)
        else
          _element.element(locator.css_or_xpath_params)
        end
        elem
      end

      def _element
        parent.instance_exec(&element_block)
      end
    end
  end
end
