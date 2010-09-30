require 'has_machine_tags/tag_methods'

begin
  require 'app/models/tag'
rescue LoadError
  class ::Tag < ActiveRecord::Base #:nodoc:
  end
end

::Tag.send :include, HasMachineTags::TagMethods
