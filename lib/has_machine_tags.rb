current_dir = File.dirname(__FILE__)
$:.unshift(current_dir) unless $:.include?(current_dir) || $:.include?(File.expand_path(current_dir))
require 'has_machine_tags/singleton_methods'
require 'has_machine_tags/tag_list'
require 'has_machine_tags/console'

module HasMachineTags
  def self.included(base) #:nodoc:
    base.extend(ClassMethods)
  end
  
  module ClassMethods
    # Options
    #   :console - Adds additional helper methods from HasMachineTags::Console to use mainly in irb.
    #   :reverse_has_many - Defines a has_many :through from tags to the model using the plural of the model name.
    def has_machine_tags(options={})
      cattr_accessor :quick_mode
      self.quick_mode = options[:quick_mode] || false
      self.class_eval do
        has_many :taggings, :as=>:taggable, :dependent=>:destroy
        has_many :tags, :through=>:taggings
        after_save :save_tags
        
        include HasMachineTags::InstanceMethods
        extend HasMachineTags::SingletonMethods
        if options[:console]
          include HasMachineTags::Console::InstanceMethods
          extend HasMachineTags::Console::ClassMethods
        end
        if respond_to?(:named_scope)
          named_scope :tagged_with, lambda{ |*args|
            find_options_for_tagged_with(*args)
          }
        end
      end
      if options[:reverse_has_many]
        model = self.to_s
        'Tag'.constantize.class_eval do
          has_many(model.tableize, :through => :taggings, :source => :taggable, :source_type =>model)
        end
      end
    end
  end
    
  module InstanceMethods
    
    def quick_mode_tag_list(list) #:nodoc:
      mtag_list = TagList.new(list)
      mtag_list = mtag_list.map {|e|
        if e.include?(":")
          namespace,other = e.split(":")
          other.split(";").map {|e| 
            e.include?("=") ? "#{namespace}:#{e}" : "#{namespace}:tags=#{e}"
          }
        else
          e
        end
      }.flatten
      TagList.new(mtag_list)
    end
    
    # Set tag list with an array of tags or comma delimited string of tags
    def tag_list=(list)
      @tag_list = current_tag_list(list)
    end
    
    def current_tag_list(list)
      quick_mode ? quick_mode_tag_list(list) : TagList.new(list)
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
