module Meese
  module Hook
    class Base
      attr_reader :block

      def initialize(block:)
        @block = block
      end

      def call_with_entity(entity)
        entity.instance_eval(&block)
      end
    end
  end
end
