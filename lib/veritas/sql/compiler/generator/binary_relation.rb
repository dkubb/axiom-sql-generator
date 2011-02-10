module Veritas
  module SQL
    module Compiler
      class Generator < Visitor

        # Generates an SQL statement for a binary relation
        class BinaryRelation < Generator

          UNION     = 'UNION'.freeze
          INTERSECT = 'INTERSECT'.freeze
          EXCEPT    = 'EXCEPT'.freeze

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

          # Visit an Intersection
          #
          # @param [Algebra::Intersection] intersection
          #
          # @return [self]
          #
          # @api private
          def visit_veritas_algebra_intersection(intersection)
            @left      = UnaryRelation.new.visit(intersection.left)
            @right     = UnaryRelation.new.visit(intersection.right)
            @operation = INTERSECT
            self
          end

          # Visit an Difference
          #
          # @param [Algebra::Difference] difference
          #
          # @return [self]
          #
          # @api private
          def visit_veritas_algebra_difference(difference)
            @left      = UnaryRelation.new.visit(difference.left)
            @right     = UnaryRelation.new.visit(difference.right)
            @operation = EXCEPT
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
            "#{@left} #{@operation} #{@right}"
          end

        end # class BinaryRelation
      end # class Generator
    end # module Compiler
  end # module SQL
end # module Veritas
