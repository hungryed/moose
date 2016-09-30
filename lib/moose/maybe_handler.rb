require_relative "maybe_handler/runner"

module Moose
  module MaybeHandler
    def maybe_block(opts = {}, &block)
      Runner.new(entity: self, call_block: block).validate_and_call(opts)
    end
  end
end
