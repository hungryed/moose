module Moose
  module Page
    class Section < Base
      class Collection
        include Enumerable
        attr_reader :browser, :element_block, :parent, :klass

        def initialize(browser:, element_block:, parent:, klass:)
          @browser = browser
          @parent = parent
          @element_block = element_block
          @klass = klass
        end

        def each(&blk)
          to_a.each(&blk)
        end

        def length
          elements.length
        end
        alias_method :size, :length

        def [](idx)
          to_a[idx]
        end

        def first
          self[0]
        end

        def last
          self[-1]
        end

        def to_a
          elements.map { |e|
            klass.new(
              :parent => parent,
              :browser => @browser,
              :element_block => proc { e }
            )
          }
        end

        private

        def method_missing(meth, *args, &block)
          to_a.map { |e|
            e.send(meth, *args, &block)
          }
        end

        def elements
          obj = collection_object
          obj.is_a?(Enumerable) ? obj : [obj]
        end

        def collection_object
          parent.instance_exec(&element_block)
        end
      end
    end
  end
end
