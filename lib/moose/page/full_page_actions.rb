require_relative "page_actions"
module Moose
  module Page
    module FullPageActions

      def self.included(klass)
        klass.include(PageActions)
        klass.extend(ClassMethods)
        klass.include(InstanceMethods)
      end

      module ClassMethods
        class NoPathGiven < Moose::Error; end
        def path=(full_path)
          @path = full_path
        end

        def path(full_path)
          self.path = path
        end

        def path
          raise NoPathGiven.new("No path provided for #{self}") unless @path
          @path
        end
      end

      module InstanceMethods
        class MissingPathParameter < Moose::Error; end

        def at_page?(opts = {})
          _full_path(opts) == browser.url
        end

        def go_there!(opts = {})
          return if at_page?(opts)
          go_to(_full_path(opts))
        end

        private

        def _path
          self.class.path
        end

        def _full_path(opts = {})
          File.join(browser.test_suite.base_url, _replaced_path(opts))
        end

        def _replaced_path(opts = {})
          current_path = _path.dup
          _matches.each do |match|
            current_path.gsub!(match, _fetch_key_from(opts, match))
          end
          _params_matches.each do |match|
            current_path.gsub!(match, _fetch_key_from(opts, match))
          end
          current_path
        end

        def _fetch_key_from(hsh, key_name)
          key_name = key_name.gsub(/^:/, "")
          hsh.fetch(key_name.to_sym) {
            hsh.fetch(key_name.to_s) { raise MissingPathParameter.new("no parameter for #{key_name}")}
          }
        end

        def _matches
          @_matches ||= begin
            regex_matches = _regex.match(_path)
            regex_matches && regex_matches.captures || []
          end
        end

        def _params_matches
          CGI::parse(_path).values.flatten
        end

        def _regex
          /^#{_path.gsub(/:([\w_]+)/, "(?<\\1>\[\^\\\/\]+)")}$/
        end
      end
    end
  end
end
