module Moose
  module TestGroup
    class Configuration < Base
      include Hook::HookHelper

      attr_accessor :run_in_threads

      def load_file(file)
        Moose.load_test_group_config_file(file: file, configuration: self)
      end

      def configure(&block)
        self.instance_eval(&block)
      end
    end
  end
end
