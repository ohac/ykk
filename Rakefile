require 'rubygems'
require 'rake'

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    gem.name = "ykk"
    gem.summary = %Q{Key Value Store.}
    gem.description = %Q{YKK is a simple key value store.}
    gem.email = "jugyo.org@gmail.com"
    gem.homepage = "http://github.com/jugyo/ykk"
    gem.authors = ["jugyo"]
    gem.add_development_dependency "rspec", ">= 1.2.9"
  end
rescue LoadError
  puts "Jeweler (or a dependency) not available. Install it with: sudo gem install jeweler"
end

require 'spec/rake/spectask'
Spec::Rake::SpecTask.new(:spec) do |spec|
  spec.libs << 'lib' << 'spec'
  spec.spec_files = FileList['spec/**/*_spec.rb']
end

Spec::Rake::SpecTask.new(:rcov) do |spec|
  spec.libs << 'lib' << 'spec'
  spec.pattern = 'spec/**/*_spec.rb'
  spec.rcov = true
end

task :spec => :check_dependencies

task :default => :spec

require 'rake/rdoctask'
Rake::RDocTask.new do |rdoc|
  version = File.exist?('VERSION') ? File.read('VERSION') : ""

  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "ykk #{version}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end
