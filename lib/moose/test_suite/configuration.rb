require 'ostruct'

module Meese
  module TestSuite
    class Configuration < Base
      class MissingEnvironment < Meese::Error; end

      include Hook::HookHelper

      def register_environment(environment, environment_hash)
        environment_cache.merge!(environment.to_sym => OpenStruct.new(environment_hash))
      end

      def base_url
        environment_object.base_url
      end

      def load_file(file)
        Meese.load_suite_config_file(file: file, configuration: self)
      end

      def configure(&block)
        self.instance_eval(&block)
      end

      def suite_hook_collection
        @suite_hook_collection ||= Hook::Collection.new
      end

      def add_before_suite_hook(&block)
        create_before_hook_from(collection: suite_hook_collection, block: block)
      end

      def add_after_suite_hook(&block)
        create_after_hook_from(collection: suite_hook_collection, block: block)
      end

      def run_test_case_with_hooks(test_case:, on_error: nil, &block)
        call_hooks_with_entity(entity: test_case, on_error: on_error, &block)
      end

      alias_method :before_each_test_case, :add_before_hook
      alias_method :after_each_test_case, :add_after_hook

      private

      def environment_object
        environment_cache.fetch(Meese.environment) {
          raise MissingEnvironment.new("no environment setup for #{Meese.environment}")
        }
      end

      def environment_cache
        @environment_cache ||= {}
      end
    end
  end
end
