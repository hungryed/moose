require_relative 'harness'
require_relative 'browser'
require_relative 'test_status'

module Meese
  class TestCase
    include TestStatus

    status_method :result
    attr_accessor :test_block, :start_time, :end_time, :result, :exception
    attr_reader :file, :extra_metadata, :test_group

    def initialize(file:, test_group:, extra_metadata: {})
      @file = file
      @test_group = test_group
      @extra_metadata = Hash[extra_metadata] || {}
    end

    def build
      Meese.load_test_case_from_file(file: file, test_case: self)
    end

    def locators
      test_case.test_group.test_suite.locators.cache
    end

    def base_url
      test_group.test_suite.configuration.base_url
    end

    def browser(index: nil, options: {})
      if index
        browsers[index]
      elsif last_browser = browsers.last
        last_browser
      else
        new_browser(options)
      end
    end

    def new_browser(test_suite: test_group.test_suite, **opts)
      browser_instance = Meese::Browser::Instance.new(
        test_suite: test_suite,
        browser_options: opts
      )
      browsers << browser_instance
      browser_instance
    end

    def run!(opts={})
      self.start_time = Time.now
      begin
        instance_eval(&test_block)
        pass!
      rescue => e
        self.exception = e
        fail!
      ensure
        teardown
        self.end_time = Time.now
        self
      end
    end

    def remove_browser(b)
      b.close!
      browsers.delete(b)
    end

    def run_as(suite, opts={}, &block)
      Meese::Harness.run_as(current_test: self, suite: suite, opts: opts, &block)
    end

    def browsers
      @browsers ||= []
    end

    private

    def teardown
      remove_browsers
    end

    def remove_browsers
      browsers.each do |b|
        remove_browser(b)
      end
    end
  end
end
