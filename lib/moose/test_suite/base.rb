require_relative "../test_group"

module Meese
  module TestSuite
    class Base
      def config
        Meese.configuration
      end
    end
  end
end
