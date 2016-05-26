require 'yaml'
require 'erb'

module Moose
  module Utilities
    class YamlFileLoader
      attr_reader :file

      def initialize(file)
        @file = file
      end

      def read
        YAML.load(ERB.new(File.read(file)).result(binding))
      end
    end
  end
end
