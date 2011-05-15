# encoding: utf-8

require 'date'
require 'time'

require 'veritas'

require 'veritas/sql/generator/visitor'

require 'veritas/sql/generator/identifier'
require 'veritas/sql/generator/attribute'
require 'veritas/sql/generator/direction'
require 'veritas/sql/generator/literal'

require 'veritas/sql/generator/function'
require 'veritas/sql/generator/function/connective'
require 'veritas/sql/generator/function/numeric'
require 'veritas/sql/generator/function/predicate'
require 'veritas/sql/generator/function/proposition'
require 'veritas/sql/generator/function/string'

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

      LEFT_PARENTHESIS  = '('.freeze
      RIGHT_PARENTHESIS = ')'.freeze

      # Return a parenthesized SQL statement (inline modification)
      #
      # @param [#to_s] sql
      #
      # @return [#to_s]
      #   same instance as sql
      #
      # @api private
      def self.parenthesize!(sql)
        sql.insert(0, LEFT_PARENTHESIS) << RIGHT_PARENTHESIS
      end

    end # module Generator
  end # module SQL
end # module Veritas
