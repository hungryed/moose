require 'require_all'
require 'watir-webdriver'
require 'colorize'
require 'json'

require "moose/version"
require 'moose/hook'
require "moose/configuration"
require "moose/world"
require 'moose/core'
require 'moose/utilities'
require 'moose/suite'

module Meese
  class << self
    def world
      ::Meese::World.instance
    end

    def configuration
      ::Meese::Configuration.instance
    end

    alias_method :config, :configuration

    def msg
      @msg ||= Utilities::Message::Delegator.new
    end

    def run!
      ::Meese::Suite::Runner.run!
    end

    def suite
      Suite::Runner.instance
    end

    def base_url_for(suite_name)
      instance_for_suite(suite_name).configuration.base_url
    end

    def instance_for_suite(suite_name)
      suite_instance = suite.instance_for_suite(suite_name)
      raise "No suite for #{suite_name} found" unless suite_instance
      suite_instance
    end

    def configure(&block)
      ::Meese::Configuration.configure(&block)
    end

    def run_test_case_with_hooks(test_group:, test_case:, options: {})
      configuration.run_test_case_with_hooks(test_case) do
        test_group.test_suite.configuration.call_hooks_with_entity(test_group.test_suite) do
          test_group.configuration.call_hooks_with_entity(test_case) do
            results << test_case.run!(options)
          end
        end
      end
    end

    def results
      @results ||= []
    end

    def configure_test_group(&block)
      @current_loading_test_group_config.configure(&block)
    end

    def load_test_group_config_file(file:, configuration:)
      @current_loading_test_group_config = configuration
      load file
      @current_loading_test_group_config = nil
    end

    def configure_suite(&block)
      @current_loading_suite_config.configure(&block)
    end

    def load_suite_config_file(file:, configuration:)
      @current_loading_suite_config = configuration
      load file
      @current_loading_suite_config = nil
    end

    def define_test_case(&block)
      @current_loading_test_case.test_block = block
    end

    def load_test_case_from_file(file:, test_case:)
      @current_loading_test_case = test_case
      load file
      @current_loading_test_case = nil
    end
  end
end
