require 'date'
require 'time'

require 'veritas'

require 'veritas/base_relation'

require 'veritas/sql/compiler/visitor'

require 'veritas/sql/compiler/generator/identifier'
require 'veritas/sql/compiler/generator/attribute'
require 'veritas/sql/compiler/generator/direction'
require 'veritas/sql/compiler/generator/literal'
require 'veritas/sql/compiler/generator/logic'

require 'veritas/sql/compiler/generator/relation'
require 'veritas/sql/compiler/generator/relation/unary'
require 'veritas/sql/compiler/generator/relation/base'
require 'veritas/sql/compiler/generator/relation/binary'
require 'veritas/sql/compiler/generator/relation/set'

require 'veritas/sql/compiler/version'

module Veritas
  module SQL
    module Compiler

      # Raised when an invalid relation is visited
      class InvalidRelationError < StandardError; end

    end # module Compiler
  end # module SQL
end # module Veritas
