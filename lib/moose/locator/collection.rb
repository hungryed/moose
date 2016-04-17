require 'yaml'
require 'erb'

module Meese
  module Locator
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
        cache.fetch(set_name) { raise "no locator set for #{set_name}" }
      end

      def locator_for(set, name)
        locator_set = locator_set_for(set)
        locator_set.fetch(name) { raise "no locator for #{name} in #{locator_set}"}
      end
    end
  end
end
