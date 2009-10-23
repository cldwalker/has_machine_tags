# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{has_machine_tags}
  s.version = "0.1.6"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Gabriel Horner"]
  s.date = %q{2009-10-22}
  s.description = %q{This plugin implements Flickr's machine tags while still maintaining standard tagging behavior. This allows for more precise tagging as tags can have unlimited contexts provided by combinations of namespaces and predicates. These unlimited contexts also make machine tags ripe for modeling relationships between objects.}
  s.email = %q{gabriel.horner@gmail.com}
  s.extra_rdoc_files = [
    "LICENSE.txt",
    "README.rdoc"
  ]
  s.files = [
    "CHANGELOG.rdoc",
    "LICENSE.txt",
    "README.rdoc",
    "Rakefile",
    "VERSION.yml",
    "generators/has_machine_tags_migration/has_machine_tags_migration_generator.rb",
    "generators/has_machine_tags_migration/templates/migration.rb",
    "init.rb",
    "lib/has_machine_tags.rb",
    "lib/has_machine_tags/console.rb",
    "lib/has_machine_tags/finder.rb",
    "lib/has_machine_tags/tag.rb",
    "lib/has_machine_tags/tag_console.rb",
    "lib/has_machine_tags/tag_list.rb",
    "lib/has_machine_tags/tag_methods.rb",
    "lib/has_machine_tags/tagging.rb",
    "rails/init.rb",
    "test/finder_test.rb",
    "test/has_machine_tags_test.rb",
    "test/schema.rb",
    "test/tag_methods_test.rb",
    "test/test_helper.rb"
  ]
  s.homepage = %q{http://tagaholic.me/has_machine_tags/}
  s.rdoc_options = ["--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubyforge_project = ["tagaholic"]
  s.rubygems_version = %q{1.3.5}
  s.summary = %q{A rails tagging plugin implementing flickr's machine tags + maybe more (semantic tags).}
  s.test_files = [
    "test/finder_test.rb",
    "test/has_machine_tags_test.rb",
    "test/schema.rb",
    "test/tag_methods_test.rb",
    "test/test_helper.rb"
  ]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
    else
    end
  else
  end
end
