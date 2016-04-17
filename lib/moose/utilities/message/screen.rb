module Meese
  module Utilities
    module Message
      class Screen
        class << self
          def clear
            STDOUT.flush
          end
        end
      end
    end
  end
end
