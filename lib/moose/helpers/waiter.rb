module Moose
  module Helpers
    module Waiter
      class NeverReturned < StandardError
        def initialize(message, full_backtrace)
          @message = message
          @full_backtrace = full_backtrace
          super(@message)
        end

        def backtrace
          BacktraceHelper.new(@full_backtrace).filtered_backtrace
        end

        def as_json(*args)
          {
            :message => @message,
            :full_backtrace => @full_backtrace && @full_backtrace.map(&:to_s)
          }
        end
      end

      def wait_until(options = {}, &block)
        options[:timeout] ||= 10

        start_time = Time.now

        begin
          until block.call
            if (Time.now - start_time) > options[:timeout]
              raise NeverReturned.new(
                "The block never returned",caller_locations
              )
            end
            sleep 0.1
          end
        rescue => e
          retry unless (Time.now - start_time) > options[:timeout]
          raise
        end
      end
    end
  end
end
