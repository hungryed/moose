module Moose
  module TestGroup
    class Base
      def read_yaml_file(file)
        Utilities::YamlFileLoader.new(file).read
      end

      def file_name_for(file)
        Utilities::FileUtils.file_name_without_ext(file)
      end

      def trimmed_file_path(file)
        Utilities::FileUtils.trim_filename(file)
      end
    end
  end
end
