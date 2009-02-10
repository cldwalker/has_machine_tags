class Tag < ActiveRecord::Base
  has_many :taggings
  validates_presence_of :name
  validates_uniqueness_of :name
  before_save :update_name_related_columns
  
  def extract_from_name(tag_name)
    (tag_name =~ /^([a-z](?:[a-z0-9_]+))\:([a-z](?:[a-z0-9_]+))\=(.+)$/) ? [$1, $2, $3] : nil
  end
  
  def update_name_related_columns
    if self.changed.include?('name') && (arr = extract_from_name(self.name))
      self[:object], self[:property], self[:value] = arr
    end
  end
end
