# encoding: utf-8

require 'date'
require 'time'

require 'axiom'

require 'axiom/sql/generator/core_ext/date'
require 'axiom/sql/generator/core_ext/date_time'

require 'axiom/sql/generator/visitor'

require 'axiom/sql/generator/identifier'
require 'axiom/sql/generator/attribute'
require 'axiom/sql/generator/direction'
require 'axiom/sql/generator/literal'

require 'axiom/sql/generator/function'
require 'axiom/sql/generator/function/aggregate'
require 'axiom/sql/generator/function/connective'
require 'axiom/sql/generator/function/numeric'
require 'axiom/sql/generator/function/predicate'
require 'axiom/sql/generator/function/proposition'
require 'axiom/sql/generator/function/string'

require 'axiom/sql/generator/relation'
require 'axiom/sql/generator/relation/unary'
require 'axiom/sql/generator/relation/base'
require 'axiom/sql/generator/relation/binary'
require 'axiom/sql/generator/relation/materialized'
require 'axiom/sql/generator/relation/set'

require 'axiom/sql/generator/relation/insertion'

require 'axiom/sql/generator/version'

module Axiom
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
end # module Axiom
