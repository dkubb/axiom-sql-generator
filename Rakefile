# encoding: utf-8

require 'rake'

require File.expand_path('../lib/veritas/sql/generator/version', __FILE__)

begin
  gem('jeweler', '~> 1.6.0') if respond_to?(:gem, true)
  require 'jeweler'

  Jeweler::Tasks.new do |gem|
    gem.name        = 'veritas-sql-generator'
    gem.summary     = 'Relational algebra SQL generator'
    gem.description = 'Generate SQL from a veritas relation'
    gem.email       = 'dan.kubb@gmail.com'
    gem.homepage    = 'https://github.com/dkubb/veritas-sql-generator'
    gem.authors     = [ 'Dan Kubb' ]

    gem.version = Veritas::SQL::Generator::VERSION
  end

  Jeweler::GemcutterTasks.new

  FileList['tasks/**/*.rake'].each { |task| import task }
rescue LoadError
  puts 'Jeweler (or a dependency) not available. Install it with: gem install jeweler -v 1.6.0'
end
