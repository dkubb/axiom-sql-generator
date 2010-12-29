require 'rubygems'
require 'backports'
require 'veritas/sql/compiler'
require 'spec'
require 'spec/autorun'

include Veritas
include Veritas::SQL::Compiler

# require spec support files and shared behavior
Dir[File.expand_path('../{support,shared}/**/*.rb', __FILE__)].each { |f| require f }

Spec::Runner.configure do |config|
end
