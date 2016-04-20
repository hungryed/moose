require 'optparse'
require 'ostruct'

module Meese
  module Core
    class ConfigurationOptions
      attr_reader :args

      def initialize(args)
        @args = args
        assign_environment
      end

      def assign_environment
        if environment = args.shift
          Meese.environment = environment.to_sym
        else
          raise "no environment specified"
        end
      end

      def moose_run_args
        # require 'pry'; binding.pry; 1
      end

      def parsed_args
        @parsed_args ||= OpenStruct.new
      end

      def parse_args
        OptionParser.new do |parser|
          parser.on()
        end
      end
    end
  end
end

