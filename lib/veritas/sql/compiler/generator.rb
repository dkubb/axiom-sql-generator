module Veritas
  module SQL
    module Compiler

      # Generates an SQL statement for a relation
      class Generator < Visitor

        EMPTY_STRING = ''.freeze

        # Return the alias name
        #
        # @return [#to_s]
        #
        # @api private
        attr_reader :name

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

      end # class Generator
    end # module Compiler
  end # module SQL
end # module Veritas
