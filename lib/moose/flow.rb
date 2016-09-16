module Moose
  class Flow
    class PageError < Moose::Error; end
    class ArgumentError < Moose::Error; end
    include Helpers::Waiter
    attr_reader :browser

    class << self
      attr_accessor :allow_extra_initial_attributes

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
        klass.initial_attributes_memo.push(*initial_attributes_memo)
        klass.allow_extra_initial_attributes = !!allow_extra_initial_attributes
      end

      def initial_attributes(*args)
        validate_attributes_of(args)
        initial_attributes_memo.push(*args)
      end

      def validate_attributes_of(args)
        args.each do |arg|
          next if arg.is_a?(Symbol)
          if arg.is_a?(Hash)
            unless arg.keys.all? { |key| key.is_a?(Symbol) }
              raise ArgumentError.new("Key names must be a symbol")
            end
          else
            raise ArgumentError.new("Values must be a Symbol or Hash")
          end
        end
      end

      def initial_attributes_memo
        @initial_attributes_memo ||= []
      end
    end

    def initialize(browser:, **initial_attributes)
      @browser = browser
      add_page_methods
      build_methods_from(initial_attributes)
    end

    private

    def build_methods_from(initial_attributes)
      self.class.initial_attributes_memo.each do |attribute|
        if attribute.is_a?(Symbol)
          return_value = initial_attributes.delete(attribute) {
            raise ArgumentError.new("Missing keyword #{attribute}")
          }
          define_memoized_method(attribute, return_value)
        elsif attribute.is_a?(Hash)
          attribute.each do |key, default_value|
            return_value = initial_attributes.delete(key) { default_value }
            define_hash_method(key, return_value)
          end
        end
      end
      initial_attributes.each do |key, return_value|
        if self.class.allow_extra_initial_attributes
          define_hash_method(key, return_value)
        else
          raise ArgumentError.new("Extra keyword #{key}")
        end
      end
    end

    def define_hash_method(key, return_value)
      if return_value.respond_to?(:call)
        return_value = instance_eval(&return_value)
      end
      define_memoized_method(key, return_value)
    end

    def define_memoized_method(meth, return_value)
      class_eval do
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

    def add_page_methods # :nodoc:
      self.class.pages.each do |page_name,page_klass|
        define_memoized_method(page_name, page_klass.new(
          :browser => browser
        ))
      end
    end
  end
end
