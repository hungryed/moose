require_relative 'harness'
require_relative 'browser'
require_relative 'test_status'
require_relative 'test_case/all'

module Meese
  class TestCase
    include TestStatus

    status_method :result
    attr_accessor :test_block, :start_time, :end_time, :result, :exception, :has_run
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
        new_browser(**options)
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
        Meese.configuration.run_test_case_with_hooks(test_case: self, on_error: :fail_with_exception) do
          test_group.test_suite.configuration.run_test_case_with_hooks(test_case: self, on_error: :fail_with_exception) do
            test_group.configuration.call_hooks_with_entity(entity: self, on_error: :fail_with_exception) do
              begin
                result = instance_eval(&test_block)
                pass_or_result!(result)
              ensure
                self.end_time = Time.now
              end
            end
          end
        end
      rescue => e
        fail_with_exception(e)
      ensure
        self.has_run = true
        teardown
        self.end_time = Time.now
        reporter.report!
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

    def keywords
      extra_metadata.fetch("keywords", {})
    end

    def trimmed_filepath
      Utilities::FileUtils.trim_filename(file)
    end

    def final_report!(opts = {})
      return unless has_run
      reporter.final_report!
    end

    def time_elapsed
      return unless end_time && start_time
      end_time - start_time
    end

    def metadata
      starting_metadata = [:time_elapsed,:result,:start_time,:end_time,:file,:exception,:keywords].inject({}) do |memo, method|
        begin
          memo.merge!(method => send(method))
          memo
        rescue => e
          # drop error for now
          memo
        end
      end
      starting_metadata.merge(extra_metadata).merge(
        :test_group => test_group.metadata
      )
    end

    private

    def fail_with_exception(err)
      self.exception = err
      fail!
    end

    def reporter
      Reporter.new(self)
    end

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
