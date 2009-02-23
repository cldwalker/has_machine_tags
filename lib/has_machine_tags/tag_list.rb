module HasMachineTags
  class TagList < Array
    cattr_accessor :delimiter
    self.delimiter = ','
    cattr_accessor :default_predicate
    self.default_predicate = 'tags'
    QUICK_MODE_DELIMITER = ';'
  
    # ==== Options:
    # [:quick_mode]  
    #   When true enables a quick mode for inputing multiple machine tags under the same namespace.
    #   These machine tags are delimited by QUICK_MODE_DELIMITER. If a predicate is not specified, default_predicate() is used.
    #     Examples:
    #     # Namespace is added to tag 'type=test'.
    #     HasMachineTags::TagList.new("gem:name=flog;type=test, user:name=seattlerb", :quick_mode=>true)
    #     => ["gem:name=flog", "gem:type=test", "user:name=seattlerb"]
    #
    #     # Namespace and default predicate (tags) are added to tag 'git'.
    #     HasMachineTags::TagList.new("gem:name=grit;git, user:name=mojombo")
    #     => ["gem:name=grit", "gem:tags=git", "user:name=mojombo"]
    def initialize(string_or_array, options={})
      @options = options
      array = string_or_array.is_a?(Array) ? string_or_array : string_or_array.split(/\s*#{delimiter}\s*/)
      array = parse_quick_mode(array) if @options[:quick_mode]
      concat array
    end
    
    def parse_quick_mode(mtag_list) #:nodoc:
      mtag_list = mtag_list.map {|e|
        if e.include?(Tag::PREDICATE_DELIMITER)
          namespace, remainder = e.split(Tag::PREDICATE_DELIMITER)
          remainder.split(QUICK_MODE_DELIMITER).map {|e| 
            e.include?(Tag::VALUE_DELIMITER) ? "#{namespace}#{Tag::PREDICATE_DELIMITER}#{e}" :
            Tag.build_machine_tag(namespace, default_predicate, e)
          }
        else
          e
        end
      }.flatten
    end
  
    def to_s #:nodoc:
      join("#{delimiter} ")
    end
  end
end