module Moose
  module Hook
    class Procsy
      attr_reader :entity, :block

      def initialize(entity, &block)
        @entity = entity
        @block = block
      end

      def wrap(&blk)
        self.class.new(entity, &blk)
      end

      def call
        block.call
      end
    end
  end
end
