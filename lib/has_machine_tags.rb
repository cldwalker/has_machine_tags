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
          has_many :taggings, :as=>:taggable, :dependent=>:destroy
          has_many :tags, :through=>:taggings
          after_save :save_tags
          
          include HasMachineTags::ActiveRecord::InstanceMethods
          extend HasMachineTags::ActiveRecord::SingletonMethods
          if respond_to?(:named_scope)
            named_scope :tagged_with, lambda{ |tags, options|
              find_options_for_find_tagged_with(tags, options)
            }
          end
        end
      end
    end
    
    module SingletonMethods
      # Pass either a tag string, or an array of strings or tags
      # 
      # Options:
      #   :exclude - Find models that are not tagged with the given tags
      #   :match_all - Find models that match all of the given tags, not just one
      #   :conditions - A piece of SQL conditions to add to the query
      def find_tagged_with(*args)
        options = find_options_for_find_tagged_with(*args)
        options.blank? ? [] : find(:all,options)
      end
      
      def find_options_for_find_tagged_with(tags, options = {})
        options.reverse_merge!(:match_all=>true)
        tags = TagList.new(tags)
        return {} if tags.empty?

        conditions = []
        conditions << sanitize_sql(options.delete(:conditions)) if options[:conditions]
        
        taggings_alias, tags_alias = "#{table_name}_taggings", "#{table_name}_tags"
        
        if options.delete(:exclude)
          tags_conditions = tags.map { |t| sanitize_sql(["#{Tag.table_name}.name = ?", t]) }.join(" OR ")
          conditions << sanitize_sql(["#{table_name}.id NOT IN (SELECT #{Tagging.table_name}.taggable_id FROM #{Tagging.table_name} LEFT OUTER JOIN #{Tag.table_name} ON #{Tagging.table_name}.tag_id = #{Tag.table_name}.id WHERE (#{tags_conditions}) AND #{Tagging.table_name}.taggable_type = #{quote_value(base_class.name)})", tags])
        else
          conditions << tags.map {|t|
            if match = Tag.match_wildcard_machine_tag(t)
              match.map {|k,v|
                sanitize_sql(["#{tags_alias}.#{k} = ?", v])
              }.join(" AND ")
            else
              sanitize_sql(["#{tags_alias}.name = ?", t])
            end
          }.join(" OR ")

          if options.delete(:match_all)
            group = "#{taggings_alias}.taggable_id HAVING COUNT(#{taggings_alias}.taggable_id) = #{tags.size}"
          end
        end
        
        { :select => "DISTINCT #{table_name}.*",
          :joins => "LEFT OUTER JOIN #{Tagging.table_name} #{taggings_alias} ON #{taggings_alias}.taggable_id = #{table_name}.#{primary_key} AND #{taggings_alias}.taggable_type = #{quote_value(base_class.name)} " +
                    "LEFT OUTER JOIN #{Tag.table_name} #{tags_alias} ON #{tags_alias}.id = #{taggings_alias}.tag_id",
          :conditions => conditions.join(" AND "),
          :group      => group
        }.update(options)
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
