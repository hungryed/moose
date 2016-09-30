require 'optparse'
require 'ostruct'
require 'fileutils'
require 'yaml'

module Moose
  module Core
    class TestStatusPersistor
      FILENAME = "moose_status.yml"
      class MissingPersistanceFile < ::Moose::Error
        def initialize(msg = "You must specify a test_status_persistence_directory in your configuration")
          super
        end
      end
      class PersistanceFileDoesNotExist < ::Moose::Error
        def initialize(msg = "No previous test status file found")
          super
        end
      end

      class << self
        def last_failed_example_filenames
          validate_file_exists!
          examples = YAML.load_file(status_filepath)
          examples.select { |example|
            example[:result] == "FAIL"
          }.map { |example|
            example[:filepath]
          }
        end

        def persist!(tests)
          return unless filepath
          ::FileUtils.mkdir_p(filepath)
          instances = tests.map { |test|
            new(test).yamlify
          }
          File.open(status_filepath, "w") { |f|
            f.write instances.to_yaml
          }
        end

        private

        def validate_file_exists!
          raise MissingPersistanceFile unless filepath
          unless File.file?(status_filepath)
            raise PersistanceFileDoesNotExist
          end
        end

        def status_filepath
          File.join(filepath, FILENAME)
        end

        def filepath
          config.test_status_persistence_directory
        end

        def config
          ::Moose.configuration
        end
      end

      attr_reader :test

      def initialize(test)
        @test = test
      end

      def yamlify
        {
          :filepath => test.trimmed_filepath,
          :result => test.result
        }
      end
    end
  end
end

