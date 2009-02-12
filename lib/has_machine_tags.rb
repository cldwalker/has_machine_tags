current_dir = File.dirname(__FILE__)
$:.unshift(current_dir) unless $:.include?(current_dir) || $:.include?(File.expand_path(current_dir))
require 'has_machine_tags/tag_list'

module HasMachineTags
  def self.included(base) #:nodoc:
    base.extend(ClassMethods)
  end
  
  module ClassMethods #:nodoc:
    def has_machine_tags
      self.class_eval do
        has_many :taggings, :as=>:taggable, :dependent=>:destroy
        has_many :tags, :through=>:taggings
        after_save :save_tags
        
        include HasMachineTags::InstanceMethods
        extend HasMachineTags::SingletonMethods
        if respond_to?(:named_scope)
          named_scope :tagged_with, lambda{ |tags, options|
            find_options_for_find_tagged_with(tags, options)
          }
        end
      end
    end
  end
  
  module SingletonMethods
    # Takes a string of delimited tags or an array of tags.
    # Note that each tag is interpreted as a possible wildcard machine tag.
    # 
    # Options:
    #   :exclude - Find models that are not tagged with the given tags
    #   :match_all - Find models that match all of the given tags, not just one, default: true
    #   :conditions - A piece of SQL conditions to add to the query
    #
    # Example:
    #  Url.tagged_with 'something' # => fetches urls tagged with 'something'
    #  Url.tagged_with 'gem:'      # => fetches urls tagged with tags that have namespace gem
    #  Url.tagged_with 'gem:, something' # =>  fetches urls that are tagged with 'something'
    #    and tags that have namespace gem
    #   
    #  Note: This method really only needs to be used for Rails < 2.1 . 
    #  Rails 2.1 and greater should use tagged_with(), which acts the same but with
    #  the benefits of named_scope.
    #
    def find_tagged_with(*args)
      options = find_options_for_find_tagged_with(*args)
      options.blank? ? [] : find(:all,options)
    end
    
    def find_options_for_find_tagged_with(tags, options = {}) #:nodoc:
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
            string = match.map {|k,v|
              sanitize_sql(["#{tags_alias}.#{k} = ?", v])
            }.join(" AND ")
            "(#{string})"
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
    # Set tag list with an array of tags or comma delimited string of tags
    def tag_list=(list)
      @tag_list = TagList.new(list)
    end

    # Fetches latest tag list for an object
    def tag_list
      @tag_list ||= self.tags.map(&:name)
    end

    protected
    # :stopdoc:
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
    #:startdoc:
  end
  
end
