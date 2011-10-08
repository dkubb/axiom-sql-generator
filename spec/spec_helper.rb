# encoding: utf-8

require 'rubygems'
require 'backports'
require 'backports/basic_object' unless RUBY_VERSION >= '1.9.2' && (RUBY_PLATFORM[/java/] || RUBY_ENGINE == 'rbx')
require 'veritas-sql-generator'
require 'spec'
require 'spec/autorun'

include Veritas

# require spec support files and shared behavior
Dir[File.expand_path('../{support,shared}/**/*.rb', __FILE__)].each { |f| require f }

Spec::Runner.configure do |config|
end
