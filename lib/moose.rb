require 'watir'
require 'colorize'
require 'json'

require "moose/version"
require "moose/error"
require "moose/world"
require 'moose/utilities'
require 'moose/core'
require "moose/assertions"
require 'moose/hook'
require "moose/configuration"
require 'moose/suite'
require 'moose/helpers/all'
require 'moose/page/all'
require 'moose/flow'

module Moose
  class NoSuiteError < Moose::Error; end

  class << self
    attr_accessor :environment

    def world
      ::Moose::World.instance
    end

    def configuration
      ::Moose::Configuration.instance
    end

    alias_method :config, :configuration

    def msg
      @msg ||= Utilities::Message::Delegator.new
    end

    def require_files!
      ::Moose::Suite::Runner.require_files!(configuration)
    end

    def run!(opts = {})
      with_cleanup {
        ::Moose::Suite::Runner.run!(opts)
      }
    end

    def suite
      Suite::Runner.instance
    end

    def base_url_for(suite_name)
      instance_for_suite(suite_name).configuration.base_url
    end

    def instance_for_suite(suite_name)
      suite_instance = suite.instance_for_suite(suite_name)
      raise NoSuiteError.new("No suite for #{suite_name} found") unless suite_instance
      suite_instance
    end

    def configure(&block)
      ::Moose::Configuration.configure(&block)
    end

    def with_cleanup
      ::Moose::Suite::Aggregator.reset!
      yield
      ::Moose::Suite::Runner.reset!
    end

    # Loading configurations (serially)

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
