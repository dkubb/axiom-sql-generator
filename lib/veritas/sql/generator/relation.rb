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
        STAR         = '*'.freeze
        EMPTY_HASH   = {}.freeze

        # Return the alias name
        #
        # @return [#to_s]
        #
        # @api private
        attr_reader :name

        # Factory method to instantiate the generator for the relation
        #
        # @param [Veritas::Relation] relation
        #
        # @return [Generator::Relation]
        #
        # @api private
        def self.visit(relation)
          klass = case relation
          when Veritas::Relation::Operation::Insertion then self::Insertion
          when Veritas::Relation::Operation::Set       then self::Set
          when Veritas::Relation::Operation::Binary    then self::Binary
          when Veritas::Relation::Operation::Unary     then self::Unary
          when Veritas::Relation::Base                 then self::Base
          when Veritas::Relation::Materialized         then self::Materialized
          else
            raise InvalidRelationError, "#{relation.class} is not a visitable relation"
          end
          klass.new.visit(relation)
        end

        # Initialize a Generator
        #
        # @return [undefined]
        #
        # @api private
        def initialize
          @sql        = EMPTY_STRING
          @extensions = {}
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

        # Return the SQL for the unary relation
        #
        # @example
        #   sql = unary_relation.to_s
        #
        # @return [#to_s]
        #
        # @api public
        def to_s
          return EMPTY_STRING unless visited?
          generate_sql(query_columns)
        end

        # Return the SQL suitable for an subquery
        #
        # @return [#to_s]
        #
        # @api private
        def to_subquery
          return EMPTY_STRING unless visited?
          Generator.parenthesize!(generate_sql(subquery_columns))
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
          instance_variable_defined?(:@name)
        end

      private

        # Return the columns to use in a query
        #
        # @return [#to_s]
        #
        # @api private
        def query_columns
          explicit_columns
        end

        # Return the columns to use in a subquery
        #
        # @return [#to_s]
        #
        # @api private
        def subquery_columns
          implicit_columns
        end

        # Return the implicit columns for the select list
        #
        # @return [#to_s]
        #
        # @api private
        def implicit_columns
          sql = [ STAR, column_list_for(@extensions) ]
          sql.reject! { |fragment| fragment.empty? }
          sql.join(SEPARATOR)
        end

        # Return the explicit columns for the select list
        #
        # @return [#to_s]
        #
        # @api private
        def explicit_columns
          @distinct.to_s + column_list_for(@extensions.merge(@columns || EMPTY_HASH))
        end

        # Return the list of columns
        #
        # @param [#map] columns
        #
        # @return [#to_s]
        #
        # @api private
        def column_list_for(columns)
          sql = columns.values_at(*@header)
          sql.compact!
          sql.join(SEPARATOR)
        end

        # Return a list of columns in a header
        #
        # @param [Veritas::Relation] relation
        #
        # @param [#[]] aliases
        #   optional aliases for the columns
        #
        # @return [Hash]
        #
        # @api private
        def columns_for(relation, aliases = EMPTY_HASH)
          columns = {}
          relation.header.each do |attribute|
            columns[aliases.fetch(attribute, attribute)] = column_for(attribute, aliases)
          end
          columns
        end

        # Return the column for an attribute
        #
        # @param [Attribute] attribute
        #
        # @param [#[]] aliases
        #   aliases for the columns
        #
        # @return [#to_s]
        #
        # @api private
        def column_for(attribute, aliases)
          if aliases.key?(attribute)
            alias_for(attribute, aliases[attribute])
          else
            dispatch(attribute)
          end
        end

        # Return the column alias for an attribute
        #
        # @param [#to_s] attribute
        #
        # @param [Attribute, nil] alias_attribute
        #   attribute to use for the alias
        #
        # @return [#to_s]
        #
        # @api private
        def alias_for(attribute, alias_attribute)
          "#{dispatch(attribute)} AS #{dispatch(alias_attribute)}"
        end

        # Add extensions for extension and summarize queries
        #
        # @param [#each] extensions
        #
        # @return [undefined]
        #
        # @api private
        def add_extensions(extensions)
          extensions.each do |attribute, function|
            @extensions[attribute] = alias_for(function, attribute)
          end
        end

      end # class Relation
    end # module Generator
  end # module SQL
end # module Veritas
