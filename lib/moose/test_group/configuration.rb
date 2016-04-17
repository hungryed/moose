module Meese
  module TestGroup
    class Configuration < Base
      include Hook::HookHelper

      attr_accessor :base_path

      def load_file(file)
        Meese.load_test_group_config_file(file: file, configuration: self)
      end

      def configure(&block)
        block.call(self)
      end
    end
  end
end
