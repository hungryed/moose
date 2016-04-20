module Meese
  module Hook
    module HookHelper
      def add_before_hook(*args, &block)
        create_before_hook_from(args: args, block: block)
      end

      def add_after_hook(*args, &block)
        create_after_hook_from(args: args, block: block)
      end

      def call_hooks_with_entity(entity, *args, &block)
        hook_collection.call_hooks_with_entity(entity, *args, &block)
      end

      def create_before_hook_from(collection: hook_collection, args:, block:)
        collection.add_before_hook(
          Before.new(args: args, block: block)
        )
      end

      def create_after_hook_from(collection: hook_collection, args:, block:)
        collection.add_after_hook(
          After.new(args: args, block: block)
        )
      end

      def hook_collection
        @hook_collection ||= Collection.new
      end
    end
  end
end
