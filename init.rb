require 'has_machine_tags'

ActiveRecord::Base.send :include, HasMachineTags::ActiveRecord
