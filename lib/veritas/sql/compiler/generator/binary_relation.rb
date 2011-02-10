module Veritas
  module SQL
    module Compiler
      class Generator < Visitor

        # Generates an SQL statement for a binary relation
        class BinaryRelation < Generator

          UNION = 'UNION'.freeze

          # Visit a Union
          #
          # @param [Algebra::Union] union
          #
          # @return [self]
          #
          # @api private
          def visit_veritas_algebra_union(union)
            @left      = UnaryRelation.new.visit(union.left)
            @right     = UnaryRelation.new.visit(union.right)
            @operation = UNION
            self
          end

          # Return the SQL for the visitable object
          #
          # @example
          #   sql = binary_relation.to_s
          #
          # @return [#to_s]
          #
          # @api public
          def to_s
            return EMPTY_STRING unless @operation
            "(#{@left} #{@operation} #{@right})"
          end

        end # class BinaryRelation
      end # class Generator
    end # module Compiler
  end # module SQL
end # module Veritas
