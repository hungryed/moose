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
        def last_failed_example_filenames(configuration)
          validate_file_exists!(configuration)
          examples = YAML.load_file(status_filepath(configuration))
          examples.select { |example|
            example[:result] == "FAIL"
          }.map { |example|
            example[:filepath]
          }
        end

        def persist!(configuration, tests)
          path = filepath(configuration)
          return unless path
          ::FileUtils.mkdir_p(path)
          instances = tests.map { |test|
            new(test).yamlify
          }
          File.open(status_filepath(configuration), "w") { |f|
            f.write instances.to_yaml
          }
        end

        private

        def validate_file_exists!(configuration)
          raise MissingPersistanceFile unless filepath(configuration)
          unless File.file?(status_filepath(configuration))
            raise PersistanceFileDoesNotExist
          end
        end

        def status_filepath(configuration)
          File.join(filepath(configuration), file_name)
        end

        def file_name
          if prefix = ENV["MOOSE_STATUS_FILE_PREFIX"]
            "#{prefix}_#{FILENAME}"
          else
            FILENAME
          end
        end

        def filepath(configuration)
          configuration.test_status_persistence_directory
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

