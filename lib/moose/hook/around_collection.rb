require_relative "procsy"
module Moose
  module Hook
    class AroundCollection
      def <<(hook)
        around_hooks << hook
      end

      def call_with_entity(entity)
        return yield if around_hooks.empty?
        initial_procsy = initial_procsy_for(entity) { yield }
        around_hooks.inject(initial_procsy) do |procsy, around_hook|
          procsy.wrap { around_hook.call_with_entity(entity, procsy) }
        end.call
      end

      def initial_procsy_for(entity, &block)
        Procsy.new(entity, &block)
      end

      def around_hooks
        @around_hooks ||= []
      end
    end
  end
end
