module HasMachineTags
# == Machine Tags
# Machine tags, also known as triple tags, are in the format: 
#   [namespace]:[predicate]=[value]
# 
# As explained here[http://www.flickr.com/groups/api/discuss/72157594497877875],
# a namespace and predicate must start with a letter a-z while its remaining characters can be any lowercase alphanumeric character
# and underscore. A value can contain any characters that normal tags use.
# 
# == Wildcard Machine Tags
# Wildcard machine tag syntax is used with Tag.machine_tags() and {tagged_with() or find_tagged_with()}[link:classes/HasMachineTags/Finder.html] of tagged objects.
# This syntax allows one to fetch items that fall under a group of tags, as specified by namespace, predicate, value or
# a combination of these ways. While this plugin supports {Flickr's wildcard format}[http://code.flickr.com/blog/2008/07/18/wildcard-machine-tag-urls/],
# it also supports its own slightly shorter format.
#
# === Examples
# 
# For a tag 'user:name=john', the following wildcards would match it:
#
# * Wild namespace (any tag with namespace user)
#     Tag.machine_tags 'user:'   # Our way
#     Tag.machine_tags 'user:*=' # Flickr way
#
# * Wild predicate (any tag with predicate name)
#     Tag.machine_tags 'name='   # Our way
#     Tag.machine_tags '*:name=' # Flickr way
#
# * Wild predicate (any tag with value john)
#     Tag.machine_tags '=john'    # Our way
#     Tag.machine_tags '*:*=john' # Flickr way
#
# * Wild namespace and predicate (any tag with namespace user and predicate name)
#     Tag.machine_tags 'user:name'  # Our way
#     Tag.machine_tags 'user:name=' # Flickr way
#
# * Wild predicate and value (any tag with predicate name and value john)
#     Tag.machine_tags 'name=john'   # Our way
#     Tag.machine_tags '*:name=john' # Flickr way
#
# * Wild namespace and value (any tag with namespace user and value john)
#     Tag.machine_tags 'user.john'   # Our way
#     Tag.machine_tags 'user:*=john' # Flickr way
#
# == Food For Thought
# So what's so great about being able to give a tag a namespace and a predicate?
# * It allows for more fine-grained tag queries by giving multiple contexts:
#
#   Say instead of having tagged with 'user:name=john' we had tagged with the traditional separate
#   tags: user, name and john. How would we know that we had meant an item to be tagged
#   as a user ie with namespace user? We wouldn't know. Any query for 'user' would return
#   all user-tagged items <b>without context</b>. With machine tags, we can have 'user' refer
#   to a particular combination of namespace, predicate and value.
#
# * It keeps tag-spaces cleaner because there are more contexts:
#
#   With traditional separate tags, tags just have a global context. So
#   if different users decide to give different meaning to the same tag, the tag starts to become
#   polluted and loses its usefulness. With the limitless contexts provided by machine tags,
#   a machine tag is less likely to pollute other tags.
#
# * It allows tagging to serve as a medium for defining relationships between objects:
#   
#   Since a machine tag tracks three attributes (namespace, predicate and value), it's possible to develop relationships
#   between the attributes. This means namespaces can have many predicates and predicates can have many values.
#   Since this closely resembles object modeling, we can start to use tagging to form relationships between tagged items and other objects.
  module TagMethods
    NAMESPACE_REGEX = "[a-z](?:[a-z0-9_]+)"
    PREDICATE_REGEX = "[a-z](?:[a-z0-9_-]+)"
    VALUE_REGEX = '.+'
    #TODO: use delimiters in this file
    PREDICATE_DELIMITER = ':'
    VALUE_DELIMITER = '='

    def self.included(base) #:nodoc:
      name_format = /\A(([^\*\=\:\.,]+)|(#{NAMESPACE_REGEX}\:#{PREDICATE_REGEX}\=#{VALUE_REGEX}))\Z/
      base.class_eval %[
        has_many :taggings
  
        validates_presence_of :name
        validates_uniqueness_of :name
        before_save :update_name_related_columns
  
        #disallow machine tags special characters and tag list delimiter OR allow machine tag format
        validates_format_of :name, :with=>name_format
      ]
      base.extend(ClassMethods)
      base.send :include, InstanceMethods
    end
    
    module ClassMethods
      # Takes a wildcard machine tag and returns matching tags.
      def machine_tags(name)
        conditions = if (match = match_wildcard_machine_tag(name))
          match.map {|k,v|
            sanitize_sql(["#{k} = ?", v])
          }.join(" AND ")
        else
          sanitize_sql(["name = ?", name])
        end
        find(:all, :conditions=>conditions)
      end
      
      # Builds a machine tag string given namespace, predicate and value.
      def build_machine_tag(namespace, predicate, value)
        "#{namespace}:#{predicate}=#{value}"
      end
      
      # Returns an array of machine tag parts: [namespace, predicate, value]
      def split_machine_tag(machine_tag)
        extract_from_name(machine_tag) || []
      end
      
      # Boolean indicating if given tag is a machine tag.
      def machine_tag?(machine_tag)
        !extract_from_name(machine_tag).nil?
      end
      
      def extract_from_name(tag_name) #:nodoc:
        (tag_name =~ /^(#{NAMESPACE_REGEX})\:(#{PREDICATE_REGEX})\=(#{VALUE_REGEX})$/) ? [$1, $2, $3] : nil
      end

      # Valid wildcards with their equivalent shortcuts
      # namespace:*=* -> namespace:
      # *:predicate=* -> predicate=
      # *:*=value     -> :value
      def match_wildcard_machine_tag(name) #:nodoc:
        if name =~ /^(#{NAMESPACE_REGEX}|\*)\:(#{PREDICATE_REGEX}|\*)\=(#{VALUE_REGEX}|\*)?$/
          result = [[:namespace, $1], [:predicate, $2], [:value, $3]].select {|k,v| ![nil,'*'].include?(v) }
          result.size == 3 ? nil : result
        #duo shortcuts
        elsif name =~ /^(#{NAMESPACE_REGEX}\:#{PREDICATE_REGEX})|(#{PREDICATE_REGEX}\=#{VALUE_REGEX})|(#{NAMESPACE_REGEX}\.#{VALUE_REGEX})$/
          $1 ? [:namespace, :predicate].zip($1.split(":")) : ($2 ? [:predicate, :value].zip($2.split("=")) :
            [:namespace, :value].zip($3.split('.')) )
        #single shortcuts
        elsif name =~ /^((#{NAMESPACE_REGEX})(?:\:)|(#{PREDICATE_REGEX})(?:\=)|(?:\=)(#{VALUE_REGEX}))$/
          $2 ? [[:namespace, $2]] : ($3 ? [[:predicate, $3]] : [[:value, $4]])
        else
          nil
        end
      end
    end
  
    module InstanceMethods
      private
  
      def update_name_related_columns
        if self.changed.include?('name') && (arr = self.class.extract_from_name(self.name))
          self[:namespace], self[:predicate], self[:value] = arr
        end
      end
    end
  end
end
