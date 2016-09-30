require_relative "../helpers/waiter"

module Moose
  module MaybeHandler
    class Runner
      class InvalidCallback < StandardError; end
      class MissingCallback < StandardError; end
      include ::Moose::Helpers::Waiter
      attr_reader :entity

      def initialize(entity:, call_block:)
        @entity = entity
        call_block.call(self)
      end

      def validate_and_call(opts = {})
        validate!
        begin
          wait_until(opts) do
            entity.instance_eval(&@loop_over)
          end
          entity.instance_eval(&@on_success) if @on_success
          true
        rescue => e
          entity.instance_eval(&@on_failure) if @on_failure
          false
        end
      end

      def on_success(&block)
        @on_success = block
      end

      def on_failure(&block)
        @on_failure = block
      end

      def loop_over(&block)
        @loop_over = block
      end

      private

      def validate!
        raise MissingCallback.new("loop_over must be defined and respond to :call") unless @loop_over
      end
    end
  end
end
