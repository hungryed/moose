require_relative "configuration"

module Moose
  module Utilities
    module Message
      class Delegator
        def report_array(message_type, array, force=false)
          array.each do |element|
            call_on_message(message_type, element, force)
          end
        end

        def configure(&block)
          yield(configuration)
        end

        def configuration
          @configuration ||= Configuration.new
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
