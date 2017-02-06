module Moose
  module Utilities
    module LogHelper
      def validate_logger!(logger)
        raise "Loggers must respond to add" unless logger.respond_to?(:add)
        raise "Loggers must respond to info" unless logger.respond_to?(:info)
        raise "Loggers must respond to debug" unless logger.respond_to?(:debug)
        raise "Loggers must respond to error" unless logger.respond_to?(:error)
        raise "Loggers must respond to fatal" unless logger.respond_to?(:fatal)
        raise "Loggers must respond to warn" unless logger.respond_to?(:warn)
      end

      def validate_io_strat!(io_strat)
        raise "Streams must respond to puts" unless io_strat.respond_to?(:puts)
      end

      def logger_type_map(type)
        Moose::Utilities::Message::Delegator.logger_type_map(type)
      end

      def send_message_to(type:, loggers:, message:)
        logger_type = logger_type_map(type)
        loggers.uniq.each { |strat| strat.send(logger_type, message) }
        message
      end

      def puts_message_to(streams:, message:)
        streams.uniq.each { |strat| strat.puts(message) }
        message
      end
    end
  end
end
