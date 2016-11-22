module Moose
  module Hook
    class Around < Base
      def call_with_entity(entity, blk)
        entity.instance_exec(entity, blk, &block)
      end
    end
  end
end
