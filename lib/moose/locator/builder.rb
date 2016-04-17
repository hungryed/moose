module Meese
  module Locator
    class Builder
      attr_reader :directory

      def initialize(directory)
        @directory = directory
      end

      def build_list
        Dir.glob(directory + "/*.yml*") { |locator_file|
          collection.add_locators_from_file(locator_file)
        }
        self
      end

      def collection
        @collection ||= Collection.new
      end
    end
  end
end
