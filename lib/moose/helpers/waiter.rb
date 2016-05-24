module Meese
  module Helpers
    module Waiter
      def wait_until(options = {}, &block)
        options[:timeout] ||= 10

        start_time = Time.now

        begin
          until block.call
            if (Time.now - start_time) > options[:timeout]
              raise "The block never returned: #{block.source_location}"
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
