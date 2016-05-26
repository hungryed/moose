module Moose
  module TestGroup
    class Base
      def moose_config
        Moose.configuration
      end

      def read_yaml_file(file)
        Utilities::YamlFileLoader.new(file).read
      end

      def file_name_for(file)
        Utilities::FileUtils.file_name_without_ext(file)
      end
    end
  end
end
