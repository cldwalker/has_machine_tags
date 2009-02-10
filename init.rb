require 'has_machine_tags'
require 'has_machine_tags/tag'
require 'has_machine_tags/tagging'

ActiveRecord::Base.send :include, HasMachineTags::ActiveRecord
