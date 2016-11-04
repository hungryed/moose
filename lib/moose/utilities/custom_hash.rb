module Moose
  module Utilities
    class CustomHash
      attr_reader :original_hash

      def initialize(original_hash)
        @original_hash = original_hash
        build_deep
      end

      def clone_keys_deep!
        modified_hash.keys.each do |key|
          raw_value = modified_hash[key]
          value = case raw_value
                  when raw_value.class == self.class
                    raw_value.clone_keys_deep!
                  when Array
                    raw_value.map { |v|
                      v.kind_of?(Hash) ? raw_value.clone_keys_deep! : v
                    }
                  else
                    raw_value
                  end
          if key.is_a?(String)
            modified_hash[key.to_sym] ||= value
          elsif key.is_a?(Symbol)
            modified_hash[key.to_s] ||= value
          end
          modified_hash[key] ||= value
        end
        self
      end

      def build_deep
        original_hash.keys.each do |key|
          raw_value = original_hash[key]
          value = case raw_value
                  when Hash
                    build_new_hash(value)
                  when Array
                    raw_value.map { |v|
                      v.kind_of?(Hash) ? build_new_hash(v) : v
                    }
                  else
                    raw_value
                  end
          if key.is_a?(String)
            modified_hash[key.to_sym] ||= value
          elsif key.is_a?(Symbol)
            modified_hash[key.to_s] ||= value
          end
          modified_hash[key] ||= value
        end
        modified_hash
      end

      def inspect
        modified_hash.inspect
      end

      def method_missing(meth, *args, &block)
        modified_hash.send(meth, *args, &block)
      end

      def modified_hash
        @modified_hash ||= {}
      end

      def build_new_hash(value)
        self.class.new(value)
      end
    end
  end
end
