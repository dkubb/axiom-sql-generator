# encoding: utf-8

require 'date'
require 'time'

require 'veritas'

require 'veritas/base_relation'

require 'veritas/sql/generator/visitor'

require 'veritas/sql/generator/identifier'
require 'veritas/sql/generator/attribute'
require 'veritas/sql/generator/direction'
require 'veritas/sql/generator/literal'
require 'veritas/sql/generator/function'

require 'veritas/sql/generator/relation'
require 'veritas/sql/generator/relation/unary'
require 'veritas/sql/generator/relation/base'
require 'veritas/sql/generator/relation/binary'
require 'veritas/sql/generator/relation/set'

require 'veritas/sql/generator/version'

module Veritas
  module SQL
    module Generator

      # Raised when an invalid relation is visited
      class InvalidRelationError < StandardError; end

    end # module Generator
  end # module SQL
end # module Veritas
