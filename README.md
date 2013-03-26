veritas-sql-generator
=====================

Relational algebra SQL generator

[![Gem Version](https://badge.fury.io/rb/veritas-sql-generator.png)][gem]
[![Build Status](https://secure.travis-ci.org/dkubb/veritas-sql-generator.png?branch=master)][travis]
[![Dependency Status](https://gemnasium.com/dkubb/veritas-sql-generator.png)][gemnasium]
[![Code Climate](https://codeclimate.com/github/dkubb/veritas-sql-generator.png)][codeclimate]
[![Coverage Status](https://coveralls.io/repos/dkubb/veritas-sql-generator/badge.png?branch=master)][coveralls]

[gem]: https://rubygems.org/gems/veritas-sql-generator
[travis]: https://travis-ci.org/dkubb/veritas-sql-generator
[gemnasium]: https://gemnasium.com/dkubb/veritas-sql-generator
[codeclimate]: https://codeclimate.com/github/dkubb/veritas-sql-generator
[coveralls]: https://coveralls.io/r/dkubb/veritas-sql-generator

Installation
------------

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

Usage
-----

```ruby
# visit every node in the relation AST
generator = Veritas::SQL::Generator::Relation.visit(relation)

# generate an SQL string
sql = generator.to_sql

# generate an SQL subquery string
subquery_sql = generator.to_subquery
```

Description
-----------

The purpose of this gem is to produce valid SQL from a [veritas](https://github.com/dkubb/veritas) relation. A relation is a representation of a query constructed using relational algebra organized into an AST. Each node in the AST corresponds to an operation defined in the algebra.

The SQL produced has been verified and tested against [PostgreSQL](http://www.postgresql.org/) 9.0.4. Dialects for [MySQL](http://www.mysql.com/), [SQLite](http://www.sqlite.org/), [Oracle](http://www.oracle.com/) and [SQL Server](http://www.microsoft.com/sqlserver/) are planned.

Contributing
------------

See [CONTRIBUTING.md](CONTRIBUTING.md) for details.

Copyright
---------

Copyright &copy; 2010-2013 Dan Kubb. See LICENSE for details.
