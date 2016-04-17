module Meese
  module Utilities
    module Message
      class Display
        attr_reader :message

        def initialize(message="")
          @message = message.to_s
        end

        def debug
          if Meese.configuration.verbose
            output = message.split("\n").map{ |line| line = "DEBUG: #{line}"}.join
            puts output.swap
          end
        end

        alias :debug_msg :debug

        def standard
          puts message
        end

        def dog
          puts "MOOSE BARKS!"
        end

        def fail
          with_background(:red)
        end

        def error
          puts message.red
        end

        def pass
          with_background(:green)
        end

        def pending
          with_background(:magenta)
        end

        def skipped
          with_background(:orange)
        end

        def warn
          puts message.yellow
        end

        def count
          print message.yellow
          Screen.clear
        end

        def incomplete
          with_background(:yellow)
        end

        def info
          puts message.blue
        end

        def starting
          output = ("\n*** #{message} ***\n")
          puts output.blue
        end

        def ending
          output = ("\n*** #{message} ***\n")
          puts output.blue
        end

        def header
          output = "\n[#{message}]\n"
          puts output.cyan
        end

        def invert
          with_background(:black)
        end

        def case_description
          output = "\n[#{message}]"
          puts output.cyan
        end

        def name
          with_background(:cyan)
        end

        def step
          puts message.to_s.yellow
        end

        def case_group
          newline
          puts message
        end

        def newline
          puts
        end

        def dot
          print '.'.yellow
        end

        private

        def with_background(background_color)
          puts message.colorize(:color => :white, :background => background_color.to_sym)
        end
      end
    end
  end
end
