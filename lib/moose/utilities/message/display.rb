module Moose
  module Utilities
    module Message
      class Display
        attr_reader :message, :force

        def initialize(message="", force = false)
          @message = message.to_s
          @force = force
        end

        def debug
          with_checks do
            output = message.split("\n").map{ |line| line = "DEBUG: #{line}"}.join
            puts output.swap
          end
        end

        alias :debug_msg :debug

        def standard
          with_checks do
            puts message
          end
        end

        def dog
          with_checks do
            puts "MOOSE BARKS!"
          end
        end

        def failure
          with_checks do
            with_background(:failure)
          end
        end

        def error
          with_checks do
            puts message.send(font_color_for(:error))
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
            puts message.send(font_color_for(:warn))
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
            puts message.send(font_color_for(:info))
          end
        end

        def banner
          with_checks do
            output = ("\n*** #{message} ***\n")
            puts output.send(font_color_for(:banner))
          end
        end

        def header
          with_checks do
            output = "\n[#{message}]\n"
            puts output.send(font_color_for(:header))
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
            puts output.send(font_color_for(:case_description))
          end
        end

        def name
          with_checks do
            with_background(:name)
          end
        end

        def step
          with_checks do
            puts message.send(font_color_for(:step))
          end
        end

        def case_group
          with_checks do
            newline
            puts message
          end
        end

        def newline
          with_checks do
            puts
          end
        end

        def dot
          with_checks do
            print '.'.send(font_color_for(:dot))
          end
        end

        private

        def font_color_for(key)
          color_configuration.send("#{key}_font_color")
        end

        def background_color_for(key)
          color_configuration.send("#{key}_background_color")
        end

        def color_configuration
          @color_configuration ||= Moose.msg.configuration
        end

        def with_checks(&block)
          return unless Moose.configuration.verbose || force
          block.call
        end

        def with_background(key)
          font_color = font_color_for(key)
          background_color = background_color_for(key)
          puts message.colorize(:color => font_color, :background => background_color.to_sym)
        end
      end
    end
  end
end
