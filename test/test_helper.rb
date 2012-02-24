require 'active_record'
require 'bacon'
require 'bacon/bits'
require 'has_machine_tags'
require File.join(File.dirname(__FILE__), '..', 'init')

#Setup logger
require 'logger'
# ActiveRecord::Base.logger = Logger.new(File.join(File.dirname(__FILE__), "test.log"))
ActiveRecord::Base.logger = Logger.new(STDERR)
ActiveRecord::Base.logger.level = Logger::WARN

#Setup db
adapter = RUBY_DESCRIPTION[/java/] ? 'jdbcsqlite3' : 'sqlite3'
ActiveRecord::Base.establish_connection(:adapter => adapter, :database => ':memory:')

#Define schema
require File.join(File.dirname(__FILE__), 'schema')
class TaggableModel < ActiveRecord::Base
  has_machine_tags
end

class Bacon::Context
  def after_all; yield; end
  def before_all; yield; end
end
