module Moose
  class Configuration
    include Hook::HookHelper
    class << self
      def instance
        @instance ||= new
      end

      def configure(&block)
        instance.configure_from_block(&block)
      end
    end

    DEFAULTS = {
      :verbose => false,
      :snapshot_directory => "snapshots",
      :snapshots => false,
      :moose_tests_directory => "moose_tests",
      :moose_test_group_directory_pattern => "test_groups/**",
      :suite_pattern => "*_suite/",
      :run_in_threads => false,
      :test_thread_count => 5,
      :headless => false,
      :browser => :chrome,
      :rerun_failed => false,
      :show_full_error_backtrace => false,
      :test_status_persistence_directory => nil,
      :environment_variables => ["MOOSE_STATUS_FILE_PREFIX"]
    }

    attr_accessor *DEFAULTS.keys

    def initialize
      DEFAULTS.each do |key, value|
        self.send("#{key}=", value)
      end
    end

    def test_thread_count=(count)
      count = count.to_i
      unless count > 0
        count = 1
      end
      @test_thread_count = count
    end

    def configure_from_block(&block)
      instance_eval(&block)
    end

    def run_hook_collection
      @run_hook_collection ||= Hook::Collection.new
    end

    def add_before_run_hook(&block)
      create_before_hook_from(collection: run_hook_collection, block: block)
    end

    def add_after_run_hook(&block)
      create_after_hook_from(collection: run_hook_collection, block: block)
    end

    def run_test_case_with_hooks(test_case:, on_error: nil, &block)
      call_hooks_with_entity(entity: test_case, on_error: on_error, &block)
    end

    alias_method :before_each_test_case, :add_before_hook
    alias_method :after_each_test_case, :add_after_hook
    alias_method :around_each_test_case, :add_around_hook
  end
end
