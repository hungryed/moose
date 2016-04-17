module Meese
  module Hook
    class Base
      attr_reader :block, :args

      def initialize(args: [], block:)
        @args = args
        @block = block
      end

      def call_with_entity(entity, *args)
        block.call(entity, *args)
      end
    end
  end
end
