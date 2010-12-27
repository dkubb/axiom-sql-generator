module Veritas
  module SQL
    module Compiler

      # Generates an SQL statement for a relation
      class Generator

        # Accept an object where each node can be visited to generate SQL
        #
        # @example
        #   generator.accept(visitable)
        #
        # @param [Object] visitable
        #   A visitable object
        #
        # @return [self]
        #
        # @api public
        def accept(visitable)
          self
        end

      end # class Generator
    end # module Compiler
  end # module SQL
end # module Veritas
