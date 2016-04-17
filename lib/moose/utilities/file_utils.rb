module Meese
  module Utilities
    class FileUtils
      class << self
        def file_name_without_ext(filepath)
          File.basename(filepath, File.extname(filepath))
        end
      end
    end
  end
end
