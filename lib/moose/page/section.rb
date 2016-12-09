module Moose
  module Page
    class Section < Base
      class InvalidElement < StandardError; end
      attr_reader :element_block, :parent

      def initialize(browser:, element_block:, parent:)
        super(browser: browser)
        @parent = parent
        @element_block = element_block
      end

      def element
        parent.instance_exec(&element_block)
      end

      def browser
        el = element
        raise InvalidElement unless el
        el
      end
    end
  end
end
