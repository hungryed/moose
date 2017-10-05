require_relative 'maybe_handler'

module Moose
  class Flow
    class PageError < Moose::Error; end
    class ArgumentError < Moose::Error; end
    include Helpers::Waiter
    include MaybeHandler
    attr_reader :browser

    class << self
      def pages
        @pages ||= {}
      end

      def page(name, klass)
        raise PageError, "Page name can not be nil" if name.nil?
        if existing_key?(name)
          raise PageError,"Duplicate definitions for Page - #{name} on Page - #{to_s}"
        end
        pages[name] = klass
      end

      def existing_key?(key_name)
        !pages[key_name].nil?
      end

      def inherited(klass)
        klass.pages.merge!(pages)
      end

      def validate_browser(browser)
        raise "Browser must be a Moose::Browser::Instance" unless browser.is_a?(Moose::Browser::Instance)
        browser
      end

      def new(browser:, **args)
        inst = super(**args)
        inst.instance_variable_set(:@browser, validate_browser(browser))
        inst.send(:_add_page_methods)
        inst
      end
    end

    def initialize(**)
    end

    private

    def run_environment
      browser && browser.run_environment
    end

    def moose_run
      browser && browser.moose_run
    end

    def _define_memoized_method(meth, return_value)
      self.class.class_eval do
        define_method(meth) do
          if memoizied = instance_variable_get("@#{meth}")
            memoizied
          else
            instance_variable_set("@#{meth}", return_value)
          end
        end
      end
      send(meth)
    end

    def _add_page_methods # :nodoc:
      self.class.pages.each do |page_name,page_klass|
        _define_memoized_method(page_name, page_klass.new(
          :browser => browser
        ))
      end
    end
  end
end
