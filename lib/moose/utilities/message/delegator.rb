require_relative "configuration"

module Moose
  module Utilities
    module Message
      class Delegator
        include Utilities::LogHelper
        attr_reader :moose_configuration
        TYPE_MAP = {
          failure: :fatal,
          debug: :debug,
          error: :error,
          warn: :warn,
        }

        class << self
          def logger_type_map(type)
            TYPE_MAP.fetch(type, :info)
          end
        end

        def initialize(moose_configuration)
          @moose_configuration = moose_configuration
        end

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

        def add_log_strategy(logger)
          validate_logger!(logger)
          log_strategies << logger
        end

        def add_output_strategy(io_strat)
          validate_io_strat!(io_strat)
          io_strategies << io_strat
        end

        def io_strategies
          @io_strategies ||= []
        end

        def log_strategies
          @log_strategies ||= []
        end

        def method_missing(meth, *args, &block)
          call_on_message(meth, *args)
        end

        def call_on_message(meth, *args)
          message = Display.new(moose_configuration, self, *args)
          message.send(meth)
        end
      end
    end
  end
end
