module Meese
  module Locator
    class Instance
      ElementTypeNotFoundError = Class.new(StandardError)
      LocatorNotValidError = Class.new(StandardError)
      attr_accessor :selector

      class << self
        def build_from_hash(hash)
          custom_hash = Utilities::CustomHash.new({})
          hash.each_pair do |name, value|
            if value.is_a?(Hash) && name != 'locate'
              custom_hash[name] = build_from_hash(value)
            else
              begin
                return by_locator(value)
              rescue ElementTypeNotFoundError, LocatorNotValidError => e
                Meese.msg.debug("Invalid element found: #{value}")
              end
            end
          end
          custom_hash.clone_keys_deep!
        end

        def by_locator(locator)
          fail LocatorNotValidError unless locator.is_a? Hash

          locator = Utilities::CustomHash.new(locator)
          locator = locator['locate'] if locator['locate']

          fail LocatorNotValidError unless locator['type']

          case locator['type'].to_sym
          when :regex
            return new("#{locator['locator']}", locator)
          when :css
            return new("#{locator['locator']}", locator)
          when :class
            return new(".#{locator['locator']}", locator)
          when :id
            return new("##{locator['locator']}", locator)
          when :xpath
            return new("//#{locator['locator']}", locator)
          when :attr
            return new("[#{locator['key']}=\"#{locator['value']}\"]", locator)
          when :text
            return new({:text => locator['locator']}, locator)
          when :attr_starts_with
            return new("[#{locator['key']}^=\"#{locator['value']}\"]", locator)
          when :attr_ends_with
            return new("[#{locator['key']}$=\"#{locator['value']}\"]", locator)
          when :attr_contains
            return new("[#{locator['key']}*=\"#{locator['value']}\"]", locator)
          when :name
            return by_locator({ :type => 'attr', :key => 'name', :value => locator['locator'], :element => locator['element'] })
          when :value
            return by_locator({ :type => 'attr', :key => 'value', :value => locator['locator'], :element => locator['element'] })
          when :href
            return by_locator({ :type => 'attr', :key => 'href', :value => locator['locator'], :element => locator['element'] })
          when :href_ends_with
            return by_locator({ :type => 'attr_ends_with', :key => 'href', :value => locator['locator'], :element => locator['element'] })
          else
            fail ElementTypeNotFoundError
          end
        end
      end

      def initialize(selector, locator)
        @selector = selector
        @locator = locator
      end

      def available?
        present? && visible? &&
          (respond_to?(:enabled?) && enabled?)
      end

      def element_type
        @element_type ||= locator['locate']['element']
      end

      def locator
        { 'locate' => @locator || {} }
      end

      def type
        @locator['type']
      end

      def css
        css? ? selector : nil
      end

      def xpath
        xpath? ? selector : nil
      end

      def watir_native
        watir_native? ? selector : nil
      end

      def watir_native?
        selector.is_a?(Hash)
      end

      def css?
        !xpath? && !watir_native?
      end

      def xpath?
        selector[0..1] == '//'
      end

      def css_or_xpath_params
        if css?
          { :css => selector }
        elsif xpath?
          { :xpath => selector }
        elsif watir_native?
          selector
        end
      end
    end
  end
end
