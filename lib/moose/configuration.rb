module Meese
  class Configuration
    include Hook::HookHelper
    class << self
      def instance
        @instance ||= new
      end

      def configure(&block)
        block.call(instance)
      end
    end

    DEFAULTS = {
      :verbose => false,
      :log_directory => "",
      :snapshot_directory => "snapshots",
      :moose_tests_directory => "moose_tests",
      :moose_test_group_directory_pattern => "test_groups/**",
      :suite_pattern => "*_suite/",
      :test_pattern => "*_tests/",
      :test_set_pattern => "*_set/",
      :run_in_threads => false,
      :test_thread_count => 5,
      :headless => false,
      :browser => :chrome,
      :rerun_failed => false,
    }

    attr_accessor *DEFAULTS.keys

    def initialize(opts={})
      DEFAULTS.each do |key, value|
        self.send("#{key}=", value)
      end
      opts.each do |key, value|
        self.send("#{key}=", value)
      end
    end

    def current_directory
      @current_directory ||= Dir.pwd
    end

    def test_thread_count=(count)
      count = count.to_i
      unless count > 0
        count = 1
      end
      @test_thread_count = count
    end

    def suite_hook_collection
      @suite_hook_collection ||= Hook::Collection.new
    end

    def add_before_suite_hook(*args, &block)
      create_before_hook_from(collection: suite_hook_collection, args: args, block: block)
    end

    def add_after_suite_hook(*args, &block)
      create_after_hook_from(collection: suite_hook_collection, args: args, block: block)
    end

    def run_test_case_with_hooks(test_case, *args, &block)
      call_hooks_with_entity(test_case, *args, &block)
    end

    alias_method :before_each_test_case, :add_before_hook
    alias_method :after_each_test_case, :add_after_hook
  end
end
