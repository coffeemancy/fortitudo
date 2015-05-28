# encoding: UTF-8
require 'bundler/setup'
require 'English'
require 'rake/tasklib'

## Style checking
#
namespace :style do
  begin
    require 'flay_task'
    desc 'Run flay to DRY clean ruby'
    FlayTask.new(:flay) do |t|
      t.verbose = true
    end
  rescue LoadError
    "#{$ERROR_INFO} -- flay tasks not loaded!"
  end

  begin
    require 'reek/rake/task'
    desc 'Run reek to identify code smells'
    Reek::Rake::Task.new(:reek) do |t|
      # warn only mode
      t.fail_on_error = false
    end
  rescue LoadError
    "#{$ERROR_INFO} -- reek tasks not loaded!"
  end

  begin
    require 'rubocop/rake_task'
    desc 'Run Ruby style checks'
    RuboCop::RakeTask.new(:rubocop)
  rescue LoadError
    "#{$ERROR_INFO} -- rubocop tasks not loaded!"
  end
end

desc 'Run all style checks'
task :style => %w{ style:flay style:reek style:rubocop }

# The default rake task
task :default => %w{ style }
