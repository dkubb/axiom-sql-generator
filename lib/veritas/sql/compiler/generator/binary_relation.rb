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
            @left      = operand_dispatch(union.left)
            @right     = operand_dispatch(union.right)
            @operation = UNION
            @name      = [ @left.name, @right.name ].uniq.join('_')
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
            @left      = operand_dispatch(intersection.left)
            @right     = operand_dispatch(intersection.right)
            @operation = INTERSECT
            @name      = [ @left.name, @right.name ].uniq.join('_')
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
            @left      = operand_dispatch(difference.left)
            @right     = operand_dispatch(difference.right)
            @operation = EXCEPT
            @name      = [ @left.name, @right.name ].uniq.join('_')
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
          # @param [Boolean] all_columns
          #   optionally specify if the SELECT list should be "*"
          #
          # @return [#to_s]
          #
          # @api public
          def to_s(all_columns = false)
            return EMPTY_STRING unless @name
            "#{@left.to_s(all_columns)} #{@operation} #{@right.to_s(all_columns)}"
          end

        private

          # Dispatch the operand to the proper handler
          #
          # @param [Visitable] visitable
          #
          # @return [Generator]
          #
          # @api private
          def operand_dispatch(visitable)
            if visitable.kind_of?(Relation::Operation::Binary)
              BinaryRelation.new.visit(visitable)
            else
              dispatch(visitable)
            end
          end

        end # class BinaryRelation
      end # class Generator
    end # module Compiler
  end # module SQL
end # module Veritas
