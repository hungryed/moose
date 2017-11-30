require_relative "page_actions"
module Moose
  module Page
    module SectionPageActions

      def self.included(klass)
        klass.include(PageActions)
        klass.send(:attr_reader, :element_block, :parent)
        klass.include(InstanceMethods)
      end

      module InstanceMethods
        class InvalidElement < StandardError; end

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
end
