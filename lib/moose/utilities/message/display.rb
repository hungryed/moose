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
            with_background(:red)
          end
        end

        def error
          with_checks do
            puts message.red
          end
        end

        def pass
          with_checks do
            with_background(:green)
          end
        end

        def pending
          with_checks do
            with_background(:magenta)
          end
        end

        def skipped
          with_checks do
            with_background(:orange)
          end
        end

        def warn
          with_checks do
            puts message.yellow
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
            with_background(:yellow)
          end
        end

        def info
          with_checks do
            puts message.blue
          end
        end

        def banner
          with_checks do
            output = ("\n*** #{message} ***\n")
            puts output.blue
          end
        end

        def header
          with_checks do
            output = "\n[#{message}]\n"
            puts output.cyan
          end
        end

        def invert
          with_checks do
            with_background(:black)
          end
        end

        def case_description
          with_checks do
            output = "\n[#{message}]"
            puts output.cyan
          end
        end

        def name
          with_checks do
            with_background(:cyan)
          end
        end

        def step
          with_checks do
            puts message.yellow
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
            print '.'.yellow
          end
        end

        private

        def with_checks(&block)
          return unless Moose.configuration.verbose || force
          block.call
        end

        def with_background(background_color)
          puts message.colorize(:color => :white, :background => background_color.to_sym)
        end
      end
    end
  end
end
