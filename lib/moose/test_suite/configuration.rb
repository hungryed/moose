module Meese
  module TestSuite
    class Configuration < Base
      include Hook::HookHelper

      attr_accessor :base_url

      def load_file(file)
        Meese.load_suite_config_file(file: file, configuration: self)
      end

      def configure(&block)
        block.call(self)
      end
    end
  end
end
