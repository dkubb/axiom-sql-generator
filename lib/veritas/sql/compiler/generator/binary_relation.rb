module Veritas
  module SQL
    module Compiler
      module Generator

        # Generates an SQL statement for a binary relation
        class BinaryRelation < Relation

          DIFFERENCE   = 'EXCEPT'.freeze
          INTERSECTION = 'INTERSECT'.freeze
          UNION        = 'UNION'.freeze

          # Visit a Union
          #
          # @param [Algebra::Union] union
          #
          # @return [self]
          #
          # @api private
          def visit_veritas_algebra_union(union)
            set_operation(UNION)
            set_operands(union)
            set_name
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
            set_operation(INTERSECTION)
            set_operands(intersection)
            set_name
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
            set_operation(DIFFERENCE)
            set_operands(difference)
            set_name
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
            generate_sql(:to_s)
          end

          # Return the SQL suitable for an inner query
          #
          # @return [#to_s]
          #
          # @api private
          def to_inner
            generate_sql(:to_inner)
          end

        private

          # Generate the SQL using the supplied method
          #
          # @param [Symbol] method
          #
          # @return [#to_s]
          #
          # @api private
          def generate_sql(method)
            return EMPTY_STRING unless visited?
            "(#{@left.send(method)}) #{@operation} (#{@right.send(method)})"
          end

          # Set the operation
          #
          # @param [#to_s] operation
          #
          # @return [undefined]
          #
          # @api private
          def set_operation(operation)
            @operation = operation
          end

          # Set the operands from the relation
          #
          # @param [Relation::Operation::Set] relation
          #
          # @return [undefined]
          #
          # @api private
          def set_operands(relation)
            @left  = operand_dispatch(relation.left)
            @right = operand_dispatch(relation.right)
          end

          # Set the name using the operands' name
          #
          # @return [undefined]
          #
          # @api private
          def set_name
            @name = [ @left.name, @right.name ].uniq.join('_').freeze
          end

          # Dispatch the operand to the proper handler
          #
          # @param [Visitable] visitable
          #
          # @return [Generator]
          #
          # @api private
          def operand_dispatch(visitable)
            generator_class = case visitable
              when Relation::Operation::Binary
                self.class
              else
                Relation::Unary
            end
            generator_class.new.visit(visitable)
          end

        end # class BinaryRelation
      end # module Generator
    end # module Compiler
  end # module SQL
end # module Veritas
