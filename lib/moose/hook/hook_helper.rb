module Moose
  module Hook
    module HookHelper
      def add_before_hook(&block)
        create_before_hook_from(block: block)
      end

      def add_after_hook(&block)
        create_after_hook_from(block: block)
      end

      def add_around_hook(&block)
        create_around_hook_from(block: block)
      end

      def call_hooks_with_entity(entity:, on_error: nil, &block)
        hook_collection.call_hooks_with_entity(entity: entity, on_error: on_error, &block)
      end

      def create_before_hook_from(collection: hook_collection, block:)
        collection.add_before_hook(
          Before.new(block: block)
        )
      end

      def create_after_hook_from(collection: hook_collection, block:)
        collection.add_after_hook(
          After.new(block: block)
        )
      end

      def create_around_hook_from(collection: hook_collection, block:)
        collection.add_around_hook(
          Around.new(block: block)
        )
      end

      def hook_collection
        @hook_collection ||= Collection.new
      end
    end
  end
end
