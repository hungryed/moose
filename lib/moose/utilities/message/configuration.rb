require_relative "configuration"

module Moose
  module Utilities
    module Message
      class Configuration
        class InvalidColor < Moose::Error; end
        VALID_COLORS = "".class.colors
        COLOR_DEFAULTS = {
          :failure_font_color => :white,
          :failure_background_color => :red,
          :pass_font_color => :white,
          :pass_background_color => :green,
          :pending_font_color => :white,
          :pending_background_color => :magenta,
          :skipped_font_color => :white,
          :skipped_background_color => :orange,
          :skipped_font_color => :white,
          :skipped_background_color => :yellow,
          :invert_font_color => :white,
          :invert_background_color => :black,
          :name_font_color => :white,
          :name_background_color => :cyan,
          :case_description_font_color => :cyan,
          :banner_font_color => :blue,
          :info_font_color => :blue,
          :header_font_color => :cyan,
          :warn_font_color => :yellow,
          :error_font_color => :red,
          :step_font_color => :yellow,
          :dot_font_color => :yellow,
        }

        attr_accessor *COLOR_DEFAULTS.keys

        def initialize
          COLOR_DEFAULTS.each do |key, value|
            build_color_methods(key)
            self.send("#{key}=", value)
          end
        end

        def build_color_methods(meth)
          class_eval do
            define_method(meth) do
              instance_variable_get("@#{meth}")
            end

            define_method("#{meth}=") do |value|
              if VALID_COLORS.include?(value)
                instance_variable_set("@#{meth}", value)
              else
                raise InvalidColor
              end
            end
          end
        end
      end
    end
  end
end
