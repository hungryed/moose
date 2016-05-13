module Meese
  module Page
    class Full < Base
      class NoPathGiven < Meese::Error; end

      class << self
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

      def at_page?(opts = {})
        _replaced_path(opts) == browser.url
      end

      def go_there!(opts = {})
        return if at_page?(opts)
        go_to(_full_path)
      end

      private

      def _path
        self.class.path
      end

      def _full_path
        File.join(browser.test_suite.base_url, _path)
      end

      def _replaced_path(opts = {})
        _full_path
      end
    end
  end
end
