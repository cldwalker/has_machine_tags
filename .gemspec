# -*- encoding: utf-8 -*-
require 'rubygems' unless Object.const_defined?(:Gem)
require File.dirname(__FILE__) + "/lib/has_machine_tags/version"

Gem::Specification.new do |s|
  s.name        = "has_machine_tags"
  s.version     = HasMachineTags::VERSION
  s.authors     = ["Gabriel Horner"]
  s.email       = "gabriel.horner@gmail.com"
  s.homepage    = "http://tagaholic.me/has_machine_tags/"
  s.summary = "A rails tagging gem which implements flickr's machine tags and maybe more (semantic tags)."
  s.description = "This gem implements Flickr's machine tags while still maintaining standard tagging behavior. This allows for more precise tagging as tags can have unlimited contexts provided by combinations of namespaces and predicates. These unlimited contexts also make machine tags ripe for modeling relationships between objects."
  s.required_rubygems_version = ">= 1.3.6"
  s.rubyforge_project = 'tagaholic'
  s.add_development_dependency 'bacon', '>= 1.1.0'
  s.add_development_dependency 'bacon-bits'
  s.files = Dir.glob(%w[{lib,test}/**/*.rb bin/* [A-Z]*.{txt,rdoc} ext/**/*.{rb,c} **/deps.rip]) + %w{Rakefile .gemspec}
  s.files += Dir.glob('generators/**/*.rb') + ['init.rb']
  s.extra_rdoc_files = ["README.rdoc", "LICENSE.txt"]
  s.license = 'MIT'
end
