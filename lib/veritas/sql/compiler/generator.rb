module Veritas
  module SQL
    module Compiler

      # Generates an SQL statement for a relation
      class Generator

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

      end # class Generator
    end # module Compiler
  end # module SQL
end # module Veritas
