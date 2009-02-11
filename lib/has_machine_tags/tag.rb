class Tag < ActiveRecord::Base
  has_many :taggings
  validates_presence_of :name
  validates_uniqueness_of :name
  before_save :update_name_related_columns

  NAMESPACE_REGEX = "[a-z](?:[a-z0-9_]+)"
  PREDICATE_REGEX = "[a-z](?:[a-z0-9_]+)"
  VALUE_REGEX = '.+'
  
  # Valid wildcards with their equivalent shortcuts
  # namespace:*=* -> namespace:
  # *:predicate=* -> predicate=
  # *:*=value     -> :value
  def self.match_wildcard_machine_tag(name)
    if name =~ /^(#{NAMESPACE_REGEX}|\*)\:(#{PREDICATE_REGEX}|\*)\=(#{VALUE_REGEX}|\*)$/
      result = [[:namespace, $1], [:predicate, $2], [:value, $3]].select {|k,v| ![nil,'*'].include?(v) }
      result.size == 3 ? nil : result
    #duo shortcuts
    elsif name =~ /^(#{NAMESPACE_REGEX}\:#{PREDICATE_REGEX})|(#{PREDICATE_REGEX}\=#{VALUE_REGEX})|(#{NAMESPACE_REGEX}\:\:#{VALUE_REGEX})$/
      $1 ? [:namespace, :predicate].zip($1.split(":")) : ($2 ? [:predicate, :value].zip($2.split("=")) :
        [:namespace, :value].zip($3.split('::')) )
    #single shortcuts
    elsif name =~ /^(#{NAMESPACE_REGEX})(?:\:)|(#{PREDICATE_REGEX})(?:\=)|(?:\=)(#{VALUE_REGEX})$/
      $1 ? [[:namespace, $1]] : ($2 ? [[:predicate, $2]] : [[:value, $3]])
    else
      nil
    end
  end
  
  def extract_from_name(tag_name)
    (tag_name =~ /^(#{NAMESPACE_REGEX})\:(#{PREDICATE_REGEX})\=(#{VALUE_REGEX})$/) ? [$1, $2, $3] : nil
  end
  
  def update_name_related_columns
    if self.changed.include?('name') && (arr = extract_from_name(self.name))
      self[:namespace], self[:predicate], self[:value] = arr
    end
  end
end
