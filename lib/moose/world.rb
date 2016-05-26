module Moose
  class World
    class << self
      def instance
        @instance ||= new
      end
    end

    attr_accessor :wants_to_quit

    def current_directory
      @current_directory ||= Dir.pwd
    end

    def gem_spec
      @gem_spec ||= Gem::Specification.find_by_name("moose")
    end
  end
end
