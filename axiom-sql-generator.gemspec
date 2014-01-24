# encoding: utf-8

require File.expand_path('../lib/axiom/sql/generator/version', __FILE__)

Gem::Specification.new do |gem|
  gem.name        = 'axiom-sql-generator'
  gem.version     = Axiom::SQL::Generator::VERSION.dup
  gem.authors     = ['Dan Kubb']
  gem.email       = 'dan.kubb@gmail.com'
  gem.description = 'Generate SQL from a axiom relation'
  gem.summary     = 'Relational algebra SQL generator'
  gem.homepage    = 'https://github.com/dkubb/axiom-sql-generator'
  gem.license     = 'MIT'

  gem.require_paths    = %w[lib]
  gem.files            = `git ls-files`.split($/)
  gem.test_files       = `git ls-files -- spec/unit`.split($/)
  gem.extra_rdoc_files = %w[LICENSE README.md CONTRIBUTING.md TODO]

  gem.add_runtime_dependency('axiom', '~> 0.2.0')

  gem.add_development_dependency('bundler', '~> 1.5', '>= 1.5.2')
end
