require 'rake'
require 'rake/testtask'
require 'rake/rdoctask'
begin
  require 'rcov/rcovtask'

  Rcov::RcovTask.new do |t|
    t.libs << 'test'
    t.test_files = FileList['test/**/*_test.rb']
    t.rcov_opts = ["-T -x '/Library/Ruby/*'"]
    t.verbose = true
  end
rescue LoadError
  puts "Rcov not available. Install it for rcov-related tasks with: sudo gem install rcov"
end

begin
  require 'jeweler'
  Jeweler::Tasks.new do |s|
    s.name = "has_machine_tags"
    s.summary = "A rails tagging plugin implementing flickr's machine tags + maybe more (semantic tags)."
    s.description = "This plugin implements Flickr's machine tags while still maintaining standard tagging behavior. This allows for more precise tagging as tags can have unlimited contexts provided by combinations of namespaces and predicates. These unlimited contexts also make machine tags ripe for modeling relationships between objects."
    s.email = "gabriel.horner@gmail.com"
    s.homepage = "http://tagaholic.me/has_machine_tags/"
    s.authors = ["Gabriel Horner"]
    s.rubyforge_project = ['tagaholic']
    s.has_rdoc = true
    s.extra_rdoc_files = ["README.rdoc", "LICENSE.txt"]
    s.files = FileList["CHANGELOG.rdoc", "README.rdoc", "LICENSE.txt", "init.rb", "Rakefile", "VERSION.yml", "{rails,generators,bin,lib,test}/**/*"]
  end

rescue LoadError
  puts "Jeweler not available. Install it for jeweler-related tasks with: sudo gem install technicalpickles-jeweler -s http://gems.github.com"
end

Rake::TestTask.new do |t|
  t.libs << 'lib'
  t.pattern = 'test/**/*_test.rb'
  t.verbose = false
end

Rake::RDocTask.new do |rdoc|
  rdoc.rdoc_dir = 'rdoc'
  rdoc.title    = 'test'
  rdoc.options << '--line-numbers' << '--inline-source'
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end

task :default => :test
