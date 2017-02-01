require_relative "configuration"

module Moose
  module Utilities
    module Message
      class Delegator
        attr_reader :moose_configuration
        TYPE_MAP = {
          failure: :fatal,
          error: :error,
        }

        def initialize(moose_configuration)
          @moose_configuration = moose_configuration
        end

        def report_array(message_type, array, force=false)
          array.each do |element|
            call_on_message(message_type, element, force)
          end
        end

        def logger_type_map(type)
          TYPE_MAP.fetch(type, :info)
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
          message = Display.new(moose_configuration, *args)
          message.send(meth)
        end
      end
    end
  end
end
