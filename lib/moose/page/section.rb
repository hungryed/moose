module Meese
  module Page
    class Section < Base
      class NoGroupName < Meese::Error; end

      class << self
        def locator_group(group_name)
          @group_name = group_name
        end

        def group_name
          raise NoGroupName.new("No group provided for #{self}") unless @group_name
          @group_name
        end
      end
    end
  end
end
