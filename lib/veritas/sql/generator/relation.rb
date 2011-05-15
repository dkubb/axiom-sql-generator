# encoding: utf-8

module Veritas
  module SQL
    module Generator

      # Abstract base class for SQL generation from a relation
      class Relation < Visitor
        extend Identifier
        include Attribute

        EMPTY_STRING = ''.freeze
        SEPARATOR    = ', '.freeze
        ALL_COLUMNS  = '*'.freeze

        # Return the alias name
        #
        # @return [#to_s]
        #
        # @api private
        attr_reader :name

        # Factory method to instantiate the generator for the relation
        #
        # @param [Veritas::Relation]
        #
        # @return [Generator::Relation]
        #
        # @api private
        def self.visit(relation)
          klass = case relation
            when Veritas::Relation::Operation::Set    then self::Set
            when Veritas::Relation::Operation::Binary then self::Binary
            when Veritas::Relation::Operation::Unary  then self::Unary
            when Veritas::Relation::Base              then self::Base
            else
              raise InvalidRelationError, "#{relation.class} is not a visitable relation"
          end
          klass.new.visit(relation)
        end

        # Return the subquery for the relation and identifier
        #
        # @param [#to_subquery] relation
        #
        # @param [#to_s] identifier
        #   optional identifier, defaults to relation.name
        #
        # @return [#to_s]
        #
        # @api private
        def self.subquery(relation, identifier = relation.name)
          "(#{relation.to_subquery}) AS #{visit_identifier(identifier)}"
        end

        # Initialize a Generator
        #
        # @return [undefined]
        #
        # @api private
        def initialize
          @sql = EMPTY_STRING
        end

        # Visit an object and generate SQL from each node
        #
        # @example
        #   generator.visit(visitable)
        #
        # @param [Visitable] visitable
        #   A visitable object
        #
        # @return [self]
        #
        # @raise [Visitor::UnknownObject]
        #   raised when the visitable object has no handler
        #
        # @api public
        def visit(visitable)
          @sql = dispatch(visitable).to_s.freeze
          freeze
        end

        # Returns the current SQL string
        #
        # @example
        #   sql = generator.to_sql
        #
        # @return [String]
        #
        # @api public
        def to_sql
          @sql
        end

        # Test if a visitable object has been visited
        #
        # @example
        #   visitor.visited?  # true or false
        #
        # @return [Boolean]
        #
        # @api public
        def visited?
          !@name.nil?
        end

      end # class Relation
    end # module Generator
  end # module SQL
end # module Veritas
