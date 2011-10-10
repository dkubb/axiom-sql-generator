# Veritas SQL Generator

Relational algebra SQL generator

[![Build Status](https://secure.travis-ci.org/dkubb/veritas-sql-generator.png)](http://travis-ci.org/dkubb/veritas-sql-generator)

## Installation

With Rubygems:

```bash
$ gem install veritas-sql-generator
$ irb -rubygems
>> require 'veritas-sql-generator'
=> true
```

With git and local working copy:

```bash
$ git clone git://github.com/dkubb/veritas-sql-generator.git
$ cd veritas-sql-generator
$ rake install
$ irb -rubygems
>> require 'veritas-sql-generator'
=> true
```

NOTE: This gem works best with ruby 1.9, however if you are using ruby 1.8 you must also install [backports](https://rubygems.org/gems/backports), then require backports and backports/basic_object, eg:

```bash
$ ruby -e 'puts RUBY_VERSION'
=> 1.8.7
$ gem install backports
$ irb -rubygems
>> require 'backports'
=> true
>> require 'backports/basic_object'
=> true
>> require 'veritas-sql-generator'  # assuming it was installed by one of the two methods above
=> true
```

## Usage

```ruby
# visit every node in the relation AST
generator = Veritas::SQL::Generator::Relation.visit(relation)

# generate an SQL string
sql = generator.to_sql

# generate an SQL subquery string
subquery_sql = generator.to_subquery
```

## Description

The purpose of this gem is to produce valid SQL from a [veritas](https://github.com/dkubb/veritas) relation. A relation is a representation of a query constructed using relational algebra organized into an AST. Each node in the AST corresponds to an operation defined in the algebra.

The SQL produced has been verified and tested against [PostgreSQL](http://www.postgresql.org/) 9.0.4. Dialects for [MySQL](http://www.mysql.com/), [SQLite](http://www.sqlite.org/), [Oracle](http://www.oracle.com/) and [SQL Server](http://www.microsoft.com/sqlserver/) are planned.

## Note on Patches/Pull Requests

* If you want your code merged into the mainline, please discuss the proposed changes with me before doing any work on it. This library is still in early development, and it may not always be clear the direction it is going. Some features may not be appropriate yet, may need to be deferred until later when the foundation for them is laid, or may be more applicable in a plugin.
* Fork the project.
* Make your feature addition or bug fix.
  * Follow this [style guide](https://github.com/dkubb/styleguide).
* Add specs for it. This is important so I don't break it in a future version unintentionally. Tests must cover all branches within the code, and code must be fully covered.
* Commit, do not mess with Rakefile, version, or history.  (if you want to have your own version, that is fine but bump version in a commit by itself I can ignore when I pull)
* Run "rake ci". This must pass and not show any regressions in the
  metrics for the code to be merged.
* Send me a pull request. Bonus points for topic branches.

## Copyright

Copyright &copy; 2010-2011 Dan Kubb. See LICENSE for details.