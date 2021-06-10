
require 'rake/testtask'
require 'yard'

  

YARD::Rake::YardocTask.new do |t|
  t.files = ['component_manager.rb', 'entity_manager.rb', 'felflame.rb']
  t.options = ['--output-dir', './docs']
  t.stats_options = ['--list-undoc']
end

Rake::TestTask.new do |t|
  t.pattern = "tests/**/*_test.rb"
end
