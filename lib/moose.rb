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
      most_recent_runner ? most_recent_runner.configuration : ::Moose::Configuration.instance
    end

    alias_method :config, :configuration

    def most_recent_runner
      ::Moose::Suite::Runner.instance
    end

    def pre_run_reset!
      ::Moose::Configuration.duplicate!
    end

    def msg
      Utilities::Message::Delegator.new(configuration)
    end

    def base_url_for(suite_name)
      msg.info("**** DEPRECATED ****")
      msg.info("Use the test case base_url_for instead")
    end

    def configure(&block)
      ::Moose::Configuration.configure(&block)
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
