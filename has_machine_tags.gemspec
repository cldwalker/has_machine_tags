# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{has_machine_tags}
  s.version = "0.1.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Gabriel Horner"]
  s.date = %q{2009-02-12}
  s.description = %q{A rails tagging plugin implementing flickr's machine tags + maybe more (semantic tags)}
  s.email = %q{gabriel.horner@gmail.com}
  s.extra_rdoc_files = ["README.rdoc", "LICENSE.txt"]
  s.files = ["README.rdoc", "LICENSE.txt", "generators/has_machine_tags_migration", "generators/has_machine_tags_migration/has_machine_tags_migration_generator.rb", "generators/has_machine_tags_migration/templates", "generators/has_machine_tags_migration/templates/migration.rb", "lib/has_machine_tags", "lib/has_machine_tags/tag.rb", "lib/has_machine_tags/tag_list.rb", "lib/has_machine_tags/tagging.rb", "lib/has_machine_tags.rb", "test/has_machine_tags_test.rb", "test/schema.rb", "test/tag_test.rb", "test/test_helper.rb"]
  s.has_rdoc = true
  s.homepage = %q{http://github.com/cldwalker/has_machine_tags}
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.1}
  s.summary = %q{A rails tagging plugin implementing flickr's machine tags + maybe more (semantic tags)}

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 2

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
    else
    end
  else
  end
end
