module Moose
  module Helpers
    class BacktraceHelper
      attr_reader :backtrace

      def initialize(backtrace)
        @backtrace = backtrace
      end

      def filtered_backtrace
        paths.map { |path|
          "\t#{path}"
        }
      end

      def paths
        if configuration.show_full_error_backtrace
          backtrace.map(&:to_s)
        elsif start_of_trace
          start_of_trace.take_while { |backtrace_path|
            !(backtrace_path.to_s =~ /^#{gem_dir}\//)
          }
        else
          []
        end
      end

      def start_of_trace
        i = backtrace.index { |backtrace_path|
          !(backtrace_path.to_s =~ /^#{gem_dir}\//)
        }
        backtrace[i..-1] if i
      end

      def configuration
        Moose.configuration
      end

      def gem_dir
        @gem_dir ||= gem_spec.gem_dir
      end

      def gem_spec
        @gem_spec ||= Moose.world.gem_spec
      end
    end
  end
end
