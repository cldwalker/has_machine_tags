require 'has_machine_tags'
require 'has_machine_tags/tag_methods'

#attempt to load constant
::Tag rescue nil
if Object.const_defined? :Tag
  ::Tag.class_eval %[include HasMachineTags::TagMethods]
else
  require 'has_machine_tags/tag'
end

require 'has_machine_tags/tagging'
ActiveRecord::Base.send :include, HasMachineTags