require 'ostruct'

module Meese
  module TestSuite
    class Configuration < Base
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
        block.call(self)
      end

      private

      def environment_object
        environment_cache.fetch(Meese.environment) { raise "no environment setup for #{Meese.environment}" }
      end

      def environment_cache
        @environment_cache ||= {}
      end
    end
  end
end
