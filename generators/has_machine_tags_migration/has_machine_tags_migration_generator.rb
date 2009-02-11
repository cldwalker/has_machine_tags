class HasMachineTagsMigrationGenerator < Rails::Generator::Base 
  def manifest 
    record do |m| 
      m.migration_template 'migration.rb', 'db/migrate', :migration_file_name => "has_machine_tags_migration"
    end
  end
end
