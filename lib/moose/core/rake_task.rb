require 'rake'
require 'rake/tasklib'
require 'shellwords'

module Moose
  module Core
    # Moose rake task
    #
    # @see Rakefile
    class RakeTask < ::Rake::TaskLib
      include ::Rake::DSL if defined?(::Rake::DSL)
      include ::Moose::Core::ShellEscape

      # Default path to the moose executable
      DEFAULT_MOOSE_PATH = File.expand_path('../../../../exe/moose', __FILE__)

      # Default pattern for moose files.
      DEFAULT_PATTERN = 'moose_tests/**{,/*/**}/*.rb'


      # Name of task. Defaults to `:moose`.
      attr_accessor :name

      # Files matching this pattern will be loaded.
      # Defaults to `'moose_tests/**{,/*/**}/*.rb'`.
      attr_accessor :pattern

      # Files matching this pattern will be excluded.
      # Defaults to `nil`.
      attr_accessor :exclude_pattern
      attr_accessor :fail_on_error

      # Use verbose output. If this is set to true, the task will print the
      # executed moose command to stdout. Defaults to `true`.
      attr_accessor :verbose

      # Command line options to pass to ruby. Defaults to `nil`.
      attr_accessor :ruby_opts

      # Path to Moose. Defaults to the absolute path to the
      # moose binary.
      attr_accessor :moose_path

      # Command line options to pass to Moose. Defaults to `nil`.
      attr_accessor :moose_opts

      def initialize(*args, &task_block)
        @name               = args.shift || :moose
        @moose_environment  = args.shift
        @ruby_opts          = nil
        @moose_opts         = nil
        @verbose            = true
        @fail_on_error      = true
        @moose_path         = DEFAULT_MOOSE_PATH
        @pattern            = DEFAULT_PATTERN

        define(args, &task_block)
      end

      # @private
      def run_task(verbose)
        command = moose_command
        puts command if verbose

        return if system(command)

        return unless fail_on_error
        $stderr.puts "#{command} failed" if verbose
        exit $?.exitstatus || 1
      end

    private

      # @private
      def define(args, &task_block)
        desc "Run Moose code examples"

        task name, *args do |_, task_args|
          RakeFileUtils.__send__(:verbose, verbose) do
            task_block.call(*[self, task_args].slice(0, task_block.arity)) if task_block
            run_task verbose
          end
        end
      end

      def test_files
        if files = ENV['MOOSE_TESTS']
          FileList[files].sort
        end
      end

      def moose_tags
        if tags = ENV["MOOSE_TAGS"]
          "--tags=#{tags.shellescape}"
        end
      end

      def moose_groups
        if groups = ENV["MOOSE_GROUPS"]
          "--groups=#{groups.shellescape}"
        end
      end

      def moose_environment
        if moose_env = ENV["MOOSE_ENVIRONMENT"]
          moose_env
        elsif @moose_environment
          @moose_environment
        else
          raise "No environment provided"
        end
      end

      def moose_command
        cmd_parts = []
        cmd_parts << RUBY
        cmd_parts << ruby_opts
        cmd_parts << moose_load_path
        cmd_parts << moose_path
        cmd_parts << moose_environment
        cmd_parts << test_files
        cmd_parts << moose_tags
        cmd_parts << moose_groups
        cmd_parts << moose_opts
        cmd_parts.flatten.reject(&blank).join(" ")
      end

      def blank
        lambda { |s| s.nil? || s == "" }
      end

      def moose_load_path
        @moose_load_path ||= begin
          core_and_support = $LOAD_PATH.grep(
            /#{File::SEPARATOR}moose[^#{File::SEPARATOR}]*#{File::SEPARATOR}lib/
          )

          "-I#{core_and_support.map(&:shellescape).join(File::PATH_SEPARATOR)}"
        end
      end
    end
  end
end
