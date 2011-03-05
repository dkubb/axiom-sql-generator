module Veritas
  module SQL
    module Compiler
      module Generator
        class Relation

          # Generates an SQL statement for a set relation
          class Set < Binary

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

            # Return the SQL for the set relation
            #
            # @example
            #   sql = set_relation.to_s
            #
            # @return [#to_s]
            #
            # @api public
            def to_s
              generate_sql(:to_s)
            end

            # Return the SQL suitable for an subquery
            #
            # @return [#to_s]
            #
            # @api private
            def to_subquery
              generate_sql(:to_subquery)
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

            # Generates an SQL statement for base relation set operands
            class Base < Unary; end

          end # class Set
        end # class Relation
      end # module Generator
    end # module Compiler
  end # module SQL
end # module Veritas
