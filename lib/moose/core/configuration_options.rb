require 'optparse'
require 'ostruct'

module Meese
  module Core
    class ConfigurationOptions
      class NoEnvironmentError < Meese::Error; end
      RUN_OPTIONS = [:tags, :groups, :run_in_threads]
      attr_reader :args

      def initialize(args)
        @args = args
      end

      def assign_environment
        if environment = args.shift
          Meese.environment = environment.to_sym
        else
          Meese.msg.banner("No environment specified")
          raise NoEnvironmentError.new("no environment specified")
        end
      end

      def parse_args
        option_parser.parse!(args)
        assign_environment
      end

      def configure_from_options(config)
        select_keys_at(*::Meese::Configuration::DEFAULTS.keys).each do |key, value|
          config.send("#{key}=", value)
        end
      end

      def moose_run_args
        run_options = select_keys_at(*RUN_OPTIONS)
        run_options.merge!({:files_to_run => files_to_run}) if files_to_run
        run_options
      end

      def files_to_run
        @files_to_run ||= Utilities::FileUtils.aggregate_files_from(args)
      end

      def parsed_args
        @parsed_args ||= OpenStruct.new
      end

      def option_parser
        OptionParser.new do |parser|
          parser.banner = "Usage: moose [environment] [options] [files or directories]\n\n"

          parser.separator <<-CONFIGURATION

            **** Configuration ****

              All the configuration options that will override options set in
              configuration base moose configuration

          CONFIGURATION

          parser.on("--[no-]threaded", "run in threads") do |bool|
            parsed_args.run_in_threads = bool
          end

          parser.on("--thread-count=COUNT", Integer, "specify thread count") do |count|
            parsed_args.test_thread_count = count
          end

          parser.on("--browser=BROWSER", "specify browser type") do |browser|
            parsed_args.browser = browser.to_sym
          end

          parser.on("-h", "--headless", "run headless") do |headless|
            parsed_args.headless = headless
          end

          parser.on("-ft", "--[no-]rerun-failures", "rerun failed tests after completion") do |rerun_failed|
            parsed_args.rerun_failed = rerun_failed
          end

          parser.on("-v", "--[no-]verbose", "run verbosely") do |verbose|
            parsed_args.verbose = verbose
          end

          parser.on("-s", "--[no-]snapshots", "take snapshots") do |snapshots|
            parsed_args.snapshots = snapshots
          end

          parser.separator <<-RUN_OPTIONS

            **** Test Run Options ****

              TODO:

          RUN_OPTIONS

          parser.on("--tags=VALUES", "--flags=VALUES", Array, 'Run examples with the specified tag, or exclude examples',
                    "by adding ~ before the tag.",
                    "  - e.g. ~slow") do |tags|
            tags.each do |tag|
              if tag =~ /^~/
                filter_type = :exclusion_filters
                tag = tag[1..-1]
              else
                filter_type = :inclusion_filters
              end

              add_tag_filter(filter_type, tag)
            end
          end

          parser.on("--groups=VALUES", Array, "Specify groups to run, or exclude groups",
                    "by adding ~ before the tag.",
                    "  - e.g. ~slow-tests") do |groups|
            groups.each do |group|
              if group =~ /^~/
                filter_type = :exclusion_filters
                group = group[1..-1]
              else
                filter_type = :inclusion_filters
              end

              add_group_filter(filter_type, group)
            end
          end
        end
      end

      def select_keys_at(*keys)
        parsed_args.to_h.select { |key, _|
          keys.include?(key)
        }
      end

      def add_tag_filter(filter_type, name)
        parsed_args.tags ||= {}
        parsed_args.tags[filter_type] ||= []
        parsed_args.tags[filter_type] << name
      end

      def add_group_filter(filter_type, name)
        parsed_args.groups ||= {}
        parsed_args.groups[filter_type] ||= []
        parsed_args.groups[filter_type] << name
      end
    end
  end
end

