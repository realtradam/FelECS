
require 'rake/testtask'
require 'yard'
require_relative './codeclimate/export-coverage'

namespace :coverage do
  desc "format coverage so it can be exported to codeclimate"
  task :format do
    ReportCoverage.format
  end

  desc "upload coverage using your key"
  task :upload do
    ReportCoverage.upload
  end
end

YARD::Rake::YardocTask.new do |t|
  t.files = ['component_manager.rb', 'entity_manager.rb', 'felflame.rb']
  t.options = ['--output-dir', './docs']
  t.stats_options = ['--list-undoc']
end

Rake::TestTask.new do |t|
  t.pattern = "tests/**/*_test.rb"
end
