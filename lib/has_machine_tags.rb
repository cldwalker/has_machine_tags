require 'has_machine_tags/finder'
require 'has_machine_tags/tag_list'
require 'has_machine_tags/console'
require 'has_machine_tags/version'
require 'has_machine_tags/tag'
require 'has_machine_tags/tagging'

module HasMachineTags
  def self.included(base) #:nodoc:
    base.extend(ClassMethods)
  end
  
  module ClassMethods
    # ==== Options:
    # [:console] When true, adds additional instance methods to use mainly in irb.
    # [:reverse_has_many] Defines a has_many :through from tags to the model using the plural of the model name.
    # [:quick_mode] When true, enables a quick mode to input machine tags with HasMachineTags::InstanceMethods.tag_list=(). See examples at HasMachineTags::TagList.new().
    def has_machine_tags(options={})
      class << self; attr_accessor :quick_mode; end
      self.quick_mode = options[:quick_mode] || false
      self.class_eval do
        has_many :taggings, :as=>:taggable, :dependent=>:destroy
        has_many :tags, :through=>:taggings
        after_save :save_tags
        
        include HasMachineTags::InstanceMethods
        extend HasMachineTags::Finder
        include HasMachineTags::Console::InstanceMethods if options[:console]

        scope_word = ActiveRecord::VERSION::STRING >= '3.0' ? 'scope' : 'named_scope'
        send scope_word, :tagged_with, lambda  { |*args|
          find_options_for_tagged_with(*args)
        }
      end
      if options[:reverse_has_many]
        model = self.to_s
        'Tag'.constantize.class_eval do
          has_many(model.tableize.to_sym, :through => :taggings, :source => :taggable, :source_type =>model)
        end
      end
    end
  end
    
  module InstanceMethods
    # Set tag list with an array of tags or comma delimited string of tags.
    def tag_list=(list)
      @tag_list = current_tag_list(list)
    end
    
    def current_tag_list(list) #:nodoc:
      TagList.new(list, :quick_mode=>self.class.quick_mode)
    end
    
    # Fetches latest tag list for an object
    def tag_list
      @tag_list ||= TagList.new(self.tags.map(&:name))
    end

    def quick_mode_tag_list
      tag_list.to_quick_mode_string
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

ActiveRecord::Base.send :include, HasMachineTags if defined?(ActiveRecord::Base)
