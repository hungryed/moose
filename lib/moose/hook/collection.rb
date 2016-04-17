module Meese
  module Hook
    class Collection
      def call_hooks_with_entity(entity, *args, &block)
        error_to_raise = nil
        call_hook_set(before_hooks, entity, *args)
        begin
          block.call
        rescue => e
          error_to_raise = e
        end
        call_hook_set(after_hooks, entity, *args)
        raise error_to_raise if error_to_raise
      end

      def add_before_hook(block_entity)
        before_hooks << block_entity
      end

      def add_after_hook(block_entity)
        after_hooks << block_entity
      end

      private

      def call_hook_set(hook_set, entity, *args)
        hook_set.each do |hook|
          hook.call_with_entity(entity, *args)
        end
      end

      def before_hooks
        @before_hooks ||= []
      end

      def after_hooks
        @after_hooks ||= []
      end
    end
  end
end
