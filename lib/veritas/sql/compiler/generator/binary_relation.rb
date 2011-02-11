module Veritas
  module SQL
    module Compiler
      class Generator

        # Generates an SQL statement for a binary relation
        class BinaryRelation < Generator
          extend Aliasable

          inheritable_alias(:visit_veritas_base_relation => :visit_veritas_relation_operation_unary)

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
            @left      = dispatch(union.left)
            @right     = dispatch(union.right)
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
            @left      = dispatch(intersection.left)
            @right     = dispatch(intersection.right)
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
            @left      = dispatch(difference.left)
            @right     = dispatch(difference.right)
            @operation = EXCEPT
            self
          end

          # Visit a Unary Relation
          #
          # @param [Relation::Operation::Unary] unary
          #
          # @return [UnaryRelation]
          #
          # @api private
          def visit_veritas_relation_operation_unary(unary)
            UnaryRelation.new.visit(unary)
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
