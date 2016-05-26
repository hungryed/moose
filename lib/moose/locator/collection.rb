require 'yaml'
require 'erb'

module Moose
  module Locator
    class NoLocatorSet < Moose::Error; end
    class NoLocator < Moose::Error; end

    class Collection
      def add_locators_from_file(file)
        cache[key_from_file(file)] ||= Instance.build_from_hash(read_file(file))
        cache
      end

      def key_from_file(file)
        File.basename(file, File.extname(file))
      end

      def read_file(file)
        YAML.load(ERB.new(File.read(file)).result(binding))
      end

      def cache
        @cache ||= Utilities::CustomHash.new({})
      end

      def locator_set_for(set_name)
        cache.fetch(set_name) { raise NoLocatorSet.new("no locator set for #{set_name}") }
      end

      def locator_for(set, *names)
        locator_set = locator_set_for(set)
        names.inject(locator_set) { |memo, name|
          memo = memo.fetch(name) { raise NoLocator.new("no locator for #{name} in #{memo}") }
        }
      end
    end
  end
end
