module Meese
  class World
    class << self
      def instance
        @instance ||= new
      end
    end

    attr_accessor :wants_to_quit
  end
end
