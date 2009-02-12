# TODO
# the flickr way
# Url.tagged_with 'gem:user=*'  # => [url2] from above

class Tag < ActiveRecord::Base
  has_many :taggings
  validates_presence_of :name
  validates_uniqueness_of :name
  before_save :update_name_related_columns
  
  NAMESPACE_REGEX = "[a-z](?:[a-z0-9_]+)"
  PREDICATE_REGEX = "[a-z](?:[a-z0-9_]+)"
  VALUE_REGEX = '.+'

  #disallow machine tags special characters and tag list delimiter OR allow machine tag format
  validates_format_of :name, :with=>/\A(([^\*\=\:\.,]+)|(#{NAMESPACE_REGEX}\:#{PREDICATE_REGEX}\=#{VALUE_REGEX}))\Z/
  
  named_scope :namespace_counts, :select=>'*, namespace as counter, count(namespace) as count', :group=>"namespace HAVING count(namespace)>=1"
  named_scope :predicate_counts, :select=>'*, predicate as counter, count(predicate) as count', :group=>"predicate HAVING count(predicate)>=1"
  named_scope :value_counts, :select=>'*, value as counter, count(value) as count', :group=>"value HAVING count(value)>=1"
  named_scope :namespace, lambda {|namespace| {:conditions=>{:namespace=>namespace}} }
  named_scope :predicate, lambda {|predicate| {:conditions=>{:predicate=>predicate}} }
  named_scope :value, lambda {|value| {:conditions=>{:value=>value}} }

  # To be used with the *counts methods.
  # For example:
  #   stat(:namespace_counts) 
  # This prints out pairs of a namespaces and their counts in the tags table.
  def self.stat(type)
    send(type).map {|e| [e.counter, e.count] }
  end

  # Takes machine tag syntax
  def self.machine_tags(name)
    conditions = if (match = match_wildcard_machine_tag(name))
      match.map {|k,v|
        sanitize_sql(["#{k} = ?", v])
      }.join(" AND ")
    else
      sanitize_sql(["name = ?", name])
    end
    find(:all, :conditions=>conditions)
  end
  
  # Valid wildcards with their equivalent shortcuts
  # namespace:*=* -> namespace:
  # *:predicate=* -> predicate=
  # *:*=value     -> :value
  def self.match_wildcard_machine_tag(name) #:nodoc:
    if name =~ /^(#{NAMESPACE_REGEX}|\*)\:(#{PREDICATE_REGEX}|\*)\=(#{VALUE_REGEX}|\*)$/
      result = [[:namespace, $1], [:predicate, $2], [:value, $3]].select {|k,v| ![nil,'*'].include?(v) }
      result.size == 3 ? nil : result
    #duo shortcuts
    elsif name =~ /^(#{NAMESPACE_REGEX}\:#{PREDICATE_REGEX})|(#{PREDICATE_REGEX}\=#{VALUE_REGEX})|(#{NAMESPACE_REGEX}\.#{VALUE_REGEX})$/
      $1 ? [:namespace, :predicate].zip($1.split(":")) : ($2 ? [:predicate, :value].zip($2.split("=")) :
        [:namespace, :value].zip($3.split('.')) )
    #single shortcuts
    elsif name =~ /^(#{NAMESPACE_REGEX})(?:\:)|(#{PREDICATE_REGEX})(?:\=)|(?:\=)(#{VALUE_REGEX})$/
      $1 ? [[:namespace, $1]] : ($2 ? [[:predicate, $2]] : [[:value, $3]])
    else
      nil
    end
  end
  
  def extract_from_name(tag_name) #:nodoc:
    (tag_name =~ /^(#{NAMESPACE_REGEX})\:(#{PREDICATE_REGEX})\=(#{VALUE_REGEX})$/) ? [$1, $2, $3] : nil
  end

  private
  
  def update_name_related_columns
    if self.changed.include?('name') && (arr = extract_from_name(self.name))
      self[:namespace], self[:predicate], self[:value] = arr
    end
  end
end
