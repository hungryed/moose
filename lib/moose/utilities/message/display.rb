module Moose
  module Utilities
    module Message
      class Display
        attr_reader :message, :force, :moose_configuration

        def initialize(moose_configuration, message="", force = false)
          @moose_configuration = moose_configuration
          @message = message.to_s
          @force = force
        end

        def debug
          with_checks do
            output = message.split("\n").map{ |line| line = "DEBUG: #{line}"}.join
            write_to_logs output.swap
          end
        end

        def write_to_logs(output="")
          message = "#{output}\n"
          logger_type = delegator.logger_type_map(type)
          moose_configuration.log_strategies.each { |strat| strat.send(logger_type, message) }
          log_strategies.each { |strat| strat.send(logger_type, message) }
          puts message
          message
        end

        alias :debug_msg :debug

        def standard
          with_checks do
            write_to_logs message
          end
        end

        def dog
          with_checks do
            write_to_logs "MOOSE BARKS!"
          end
        end

        def failure
          with_checks do
            with_background(:failure)
          end
        end

        def error
          with_checks do
            write_to_logs message.send(font_color_for(:error))
          end
        end

        def pass
          with_checks do
            with_background(:pass)
          end
        end

        def pending
          with_checks do
            with_background(:pending)
          end
        end

        def skipped
          with_checks do
            with_background(:skipped)
          end
        end

        def warn
          with_checks do
            write_to_logs message.send(font_color_for(:warn))
          end
        end

        def count
          with_checks do
            step
          end
          Screen.clear
        end

        def incomplete
          with_checks do
            with_background(:incomplete)
          end
        end

        def info
          with_checks do
            write_to_logs message.send(font_color_for(:info))
          end
        end

        def banner
          with_checks do
            output = ("\n*** #{message} ***\n")
            write_to_logs output.send(font_color_for(:banner))
          end
        end

        def header
          with_checks do
            output = "\n[#{message}]\n"
            write_to_logs output.send(font_color_for(:header))
          end
        end

        def invert
          with_checks do
            with_background(:invert)
          end
        end

        def case_description
          with_checks do
            output = "\n[#{message}]"
            write_to_logs output.send(font_color_for(:case_description))
          end
        end

        def name
          with_checks do
            with_background(:name)
          end
        end

        def step
          with_checks do
            write_to_logs message.send(font_color_for(:step))
          end
        end

        def case_group
          with_checks do
            newline
            write_to_logs message
          end
        end

        def newline
          with_checks do
            write_to_logs
          end
        end

        def dot
          with_checks do
            print '.'.send(font_color_for(:dot))
          end
        end

        def add_logger(logger)
          raise "Loggers must respond to write" unless logger.respond_to?(:write)
          log_strategies << logger
        end

        def remove_logger(logger)
          log_strategies.delete(logger)
          log_strategies
        end

        private

        def delegator
          @delegator ||= Utilities::Message::Delegator.new(moose_configuration)
        end

        def log_strategies
          @log_strategies ||= []
        end

        def font_color_for(key)
          color_configuration.send("#{key}_font_color")
        end

        def background_color_for(key)
          color_configuration.send("#{key}_background_color")
        end

        def color_configuration
          @color_configuration ||= moose_configuration.msg_configuration
        end

        def with_checks(&block)
          return unless moose_configuration.verbose || force
          block.call
        end

        def with_background(key)
          font_color = font_color_for(key)
          background_color = background_color_for(key)
          write_to_logs message.colorize(:color => font_color, :background => background_color.to_sym)
        end
      end
    end
  end
end
