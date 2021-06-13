
#require 'rake/testtask'
require 'rubygems'
require 'bundler/setup'
require 'rspec/core/rake_task'
require 'yard'
require_relative './codeclimate/export-coverage'


task :default => [:spec, :yard, 'coverage:format']

# For installing FelPacks
Gem::Specification.find_all.each do |a_gem|
  next unless a_gem.name.include? 'felpack-'

  Dir.glob("#{a_gem.gem_dir}/lib/#{a_gem.name.gsub('-', '/')}/tasks/*.rake").each { |r| load r }
end

namespace :coverage do
  desc 'format coverage so it can be exported to codeclimate'
  task :format do
    ReportCoverage.format
  end

  desc 'upload coverage using your key'
  task :upload do
    ReportCoverage.upload
  end
end

YARD::Rake::YardocTask.new do |t|
  t.files = ['system_manager.rb', 'component_manager.rb', 'entity_manager.rb', 'felflame.rb']
  t.options = ['--output-dir', './docs', 'yardoc --markup=markdown|textile|rdoc(default)']
  t.stats_options = ['--list-undoc']
end

#Rake::TestTask.new do |t|
#  t.pattern = "tests/**/*_test.rb"
#end

RSpec::Core::RakeTask.new :spec
