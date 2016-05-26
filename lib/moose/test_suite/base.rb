require_relative "../test_group"

module Moose
  module TestSuite
    class Base
      def config
        Moose.configuration
      end
    end
  end
end
