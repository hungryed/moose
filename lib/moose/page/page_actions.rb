module Moose
  module Page
    module PageActions
      class ElementError < Moose::Error; end
      class SectionError < Moose::Error; end

      def self.included(klass)
        klass.extend(ClassMethods)
        klass.include(InstanceMethods)
        klass.send(:attr_reader, :browser)
        klass.include(Utilities::Inspectable)
        klass.inspector(:browser)
        klass.include(Actions)
      end

      module ClassMethods
        def elements
          parent_elements.merge(self_elements)
        end

        def self_elements
          @self_elements ||= {}
        end

        def parent_elements
          @parent_elements ||= {}
        end

        def element(name,&block)
          raise ElementError, "Element name can not be nil" if name.nil?
          if existing_key?(name)
            raise ElementError,"Duplicate definitions for Element - #{name} on Page - #{to_s}"
          end
          self_elements[name] = block
        end

        def self_sections
          @self_sections ||= {}
        end

        def parent_sections
          @parent_sections ||= {}
        end

        def sections
          parent_sections.merge(self_sections)
        end

        def section(name, klass, &block)
          raise SectionError, "Section name can not be nil" if name.nil?
          if existing_key?(name)
            raise SectionError,"Duplicate definitions for Section - #{name} on Page - #{to_s}"
          end
          self_sections[name] = {
            :klass => klass,
            :block => block
          }
        end

        def self_section_collections
          @self_section_collections ||= {}
        end

        def parent_section_collections
          @parent_section_collections ||= {}
        end

        def section_collections
          parent_section_collections.merge(self_section_collections)
        end

        def section_collection(name, klass, &block)
          raise SectionError, "Sections name can not be nil" if name.nil?
          if existing_key?(name)
            raise SectionError,"Duplicate definitions for Sections - #{name} on Page - #{to_s}"
          end
          self_section_collections[name] = {
            :klass => klass,
            :block => block
          }
        end

        def existing_key?(key_name)
          !self_elements[key_name].nil? || !self_sections[key_name].nil? || !self_section_collections[key_name].nil?
        end

        def inherited(klass)
          klass.parent_elements.merge!(elements)
          klass.parent_sections.merge!(sections)
          klass.parent_section_collections.merge!(section_collections)
        end
      end

      module InstanceMethods
        def initialize(browser:)
          @browser = browser
          add_element_methods
          add_section_methods
          add_sections_methods
        end

        def go_to(path)
          browser.goto(path)
          wait_until do
            browser.ready_state == 'complete'
          end
        end

        private

        def run_environment
          browser && browser.run_environment
        end

        def moose_run
          browser && browser.moose_run
        end

        def add_element_methods # :nodoc:
          self.class.elements.each do |element_name,element_block|
            add_block_method(element_name, element_block)
          end
        end

        def add_sections_methods # :nodoc:
          self.class.section_collections.each do |section_name,section_details|
            klass = section_details.fetch(:klass)
            section_block = section_details.fetch(:block)

            self.class.class_eval do
              define_method(section_name) do
                if memoizied = instance_variable_get("@#{section_name}")
                  memoizied
                else
                  instance_variable_set("@#{section_name}", Section::Collection.new(
                    :parent => self,
                    :browser => @browser,
                    :klass => klass,
                    :element_block => section_block
                  ))
                end
              end
            end
          end
        end

        def add_section_methods # :nodoc:
          self.class.sections.each do |section_name,section_details|
            klass = section_details.fetch(:klass)
            section_block = section_details.fetch(:block)

            self.class.class_eval do
              define_method(section_name) do
                if memoizied = instance_variable_get("@#{section_name}")
                  memoizied
                else
                  instance_variable_set("@#{section_name}", klass.new(
                    :parent => self,
                    :browser => @browser,
                    :element_block => section_block
                  ))
                end
              end
            end
          end
        end

        def add_block_method(method_name, block) # :nodoc:
          self.class.class_eval do
            define_method(method_name) do |*args|
              self.instance_exec(*args, &block)
            end
          end
        end
      end
    end
  end
end
