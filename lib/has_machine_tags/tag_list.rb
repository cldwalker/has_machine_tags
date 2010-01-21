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
            (@options[:default_predicate] ? Tag.build_machine_tag(namespace, @options[:default_predicate].call(e, namespace), e) :
            Tag.build_machine_tag(namespace, default_predicate, e))
          }
        else
          e
        end
      }.flatten
    end

    def primary_namespace #:nodoc:
      namespace_hashes.sort {|x,y| y[1].size <=> x[1].size }[0][0]
    end

    def namespace_hashes #:nodoc:
      self.inject({}) {|h, e|
        namespace, *predicate_value = Tag.split_machine_tag(e)
        (h[namespace] ||= []) << predicate_value unless namespace.nil?
        h
      }
    end

    def non_machine_tags
      self.reject {|e| Tag.machine_tag?(e)}
    end

    # Converts tag_list to a stringified version of quick_mode.
    def to_quick_mode_string
      machine_tags = namespace_hashes.map {|namespace, predicate_values|
        "#{namespace}:" + predicate_values.map {|pred, value|
          pred == self.default_predicate ? value : "#{pred}#{Tag::VALUE_DELIMITER}#{value}"
        }.join(QUICK_MODE_DELIMITER)
      }
      (machine_tags + non_machine_tags).join("#{delimiter} ")
    end

    def to_s #:nodoc:
      join("#{delimiter} ")
    end
  end
end