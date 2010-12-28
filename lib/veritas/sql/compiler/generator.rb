module Veritas
  module SQL
    module Compiler

      # Generates an SQL statement for a relation
      class Generator

        # Initialize a Generator
        #
        # @return [undefined]
        #
        # @api private
        def initialize
          @sql = ''
        end

        # Visit an object and generate SQL from each node
        #
        # @example
        #   generator.visit(visitable)
        #
        # @param [Object] visitable
        #   A visitable object
        #
        # @return [self]
        #
        # @api public
        def visit(visitable)
          self
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

      end # class Generator
    end # module Compiler
  end # module SQL
end # module Veritas
