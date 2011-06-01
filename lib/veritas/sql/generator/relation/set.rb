# encoding: utf-8

module Veritas
  module SQL
    module Generator
      class Relation

        # Generates an SQL statement for a set relation
        class Set < Binary

          DIFFERENCE   = 'EXCEPT'.freeze
          INTERSECTION = 'INTERSECT'.freeze
          UNION        = 'UNION'.freeze

          # Normalize the headers of the operands
          #
          # This is necessary to make sure the columns are in the correct
          # order when generating SQL.
          #
          # @param [Relation::Operation::Set] relation
          #
          # @return [Relation::Operation::Set]
          #
          # @api private
          def self.normalize_operand_headers(relation)
            left        = relation.left
            right       = relation.right
            left_header = left.header
            if left_header.to_a != right.header.to_a
              relation.class.new(left, right.project(left_header))
            else
              relation
            end
          end

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

        private

          # Generate the SQL using the supplied method
          #
          # @return [#to_s]
          #
          # @api private
          def generate_sql(*)
            "(#{@left}) #{@operation} (#{@right})"
          end

          # Set the operands from the relation
          #
          # @param [Relation::Operation::Set] relation
          #
          # @return [undefined]
          #
          # @api private
          def set_operands(relation)
            super self.class.normalize_operand_headers(relation)
          end

          # Generates an SQL statement for base relation set operands
          class Base < Relation::Base; end

        end # class Set
      end # class Relation
    end # module Generator
  end # module SQL
end # module Veritas
