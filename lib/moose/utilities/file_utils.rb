module Moose
  module Utilities
    class FileUtils
      class << self
        def trim_filename(filename, removal_path = Moose.world.current_directory)
          filename.gsub(/^#{removal_path}/, ".")
        end

        def file_name_without_ext(filepath)
          File.basename(filepath, File.extname(filepath))
        end

        def aggregate_files_from(array_of_options)
          return [] unless array_of_options.length > 0
          array_of_options.each_with_object([]) do |file_or_directory, memo|
            memo.push(*ruby_files_from(file_or_directory))
            memo
          end
        end

        def ruby_files_from(file_or_directory)
          return [] unless file_or_directory
          return [file_or_directory].compact if File.file?(file_or_directory)
          memo = []
          Dir.glob(File.join(file_or_directory, "/**/*.rb")) { |file|
            memo << file
          }
          memo
        end

        def file_names_match?(file_one, file_two)
          file_two =~ /#{file_one}/ || file_one =~ /#{file_two}/
        end
      end
    end
  end
end
