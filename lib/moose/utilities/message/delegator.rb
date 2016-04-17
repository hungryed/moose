module Meese
  module Utilities
    module Message
      class Delegator
        def method_missing(meth, *args, &block)
          call_on_message(meth, *args)
        end

        def call_on_message(meth, *args)
          message = Display.new(*args)
          message.send(meth)
        end
      end
    end
  end
end
