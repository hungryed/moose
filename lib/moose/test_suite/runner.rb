module Meese
  module TestSuite
    class Runner < Base
      attr_reader :directory

      def initialize(directory)
        @directory = directory
      end

    end
  end
end
