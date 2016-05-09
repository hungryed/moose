module Meese
  module Utilities
    module Message
      class Delegator
        def report_array(message_type, array)
          array.each do |element|
            call_on_message(message_type, element)
          end
        end

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
