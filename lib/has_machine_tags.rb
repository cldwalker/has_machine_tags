current_dir = File.dirname(__FILE__)
$:.unshift(current_dir) unless $:.include?(current_dir) || $:.include?(File.expand_path(current_dir))
require 'has_machine_tags/tag_list'

module HasMachineTags
  module ActiveRecord
    def self.included(base)
      base.extend(ClassMethods)
    end
    
    module ClassMethods
      def has_machine_tags(*args)
        self.class_eval do
          include HasMachineTags::ActiveRecord::InstanceMethods
          
          has_many :taggings, :as=>:taggable, :dependent=>:destroy
          has_many :tags, :through=>:taggings
          after_save :save_tags
        end
      end
    end
    
    module InstanceMethods
      def tag_list=(list)
        @tag_list = TagList.new(list)
      end

      def tag_list
        @tag_list ||= self.tags.map(&:name)
      end

      protected
        def save_tags
          self.class.transaction do
            delete_unused_tags
            add_new_tags
          end
        end

        def delete_unused_tags
          unused_tags = tags.select {|e| !tag_list.include?(e.name) }
          tags.delete(*unused_tags)
        end

        def add_new_tags
          new_tags = tag_list - (self.tags || []).map(&:name)
          new_tags.each do |t|
            self.tags << Tag.find_or_initialize_by_name(t)
          end
        end
    end
    
  end
end
