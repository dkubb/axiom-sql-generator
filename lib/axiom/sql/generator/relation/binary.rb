# encoding: utf-8

module Axiom
  module SQL
    module Generator
      class Relation

        # Generates an SQL statement for a Binary relation
        class Binary < Relation

          JOIN       = 'NATURAL JOIN'.freeze
          PRODUCT    = 'CROSS JOIN'.freeze
          LEFT_NAME  = 'left'.freeze
          RIGHT_NAME = 'right'.freeze

          # Visit an Join
          #
          # @param [Algebra::Join] join
          #
          # @return [self]
          #
          # @api private
          def visit_axiom_algebra_join(join)
            @header = join.header
            set_operation(JOIN)
            set_columns(join)
            set_operands(join)
            set_name
            self
          end

          # Visit an Product
          #
          # @param [Algebra::Product] product
          #
          # @return [self]
          #
          # @api private
          def visit_axiom_algebra_product(product)
            @header = product.header
            set_operation(PRODUCT)
            set_columns(product)
            set_operands(product)
            set_name
            self
          end

        private

          # Generate the SQL using the supplied columns
          #
          # @param [String] columns
          #
          # @return [#to_s]
          #
          # @api private
          def generate_sql(columns)
            "SELECT #{columns} FROM #{@left.to_subquery} AS #{visit_identifier(LEFT_NAME)} #{@operation} #{@right.to_subquery} AS #{visit_identifier(RIGHT_NAME)}"
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

          # Set the columns from the relation
          #
          # @param [Relation::Operation::Binary] relation
          #
          # @return [undefined]
          #
          # @api private
          def set_columns(relation)
            @columns = columns_for(relation)
          end

          # Set the operands from the relation
          #
          # @param [Relation::Operation::Binary] relation
          #
          # @return [undefined]
          #
          # @api private
          def set_operands(relation)
            util   = self.class
            @left  = util.visit(relation.left)
            @right = util.visit(relation.right)
          end

          # Set the name using the operands' name
          #
          # @return [undefined]
          #
          # @api private
          def set_name
            @name = [@left.name, @right.name].uniq.join(UNDERSCORE).freeze
          end

          # Generates an SQL statement for base relation binary operands
          class Base < Relation::Base

            # Return the SQL suitable for an subquery
            #
            # Does not parenthesize the query
            #
            # @return [#to_s]
            #
            # @api private
            def to_subquery
              return EMPTY_STRING unless visited?
              generate_sql
            end

          private

            # Generate the SQL for this base relation
            #
            # @return [#to_s]
            #
            # @api private
            def generate_sql(*)
              @from
            end

          end # class Base
        end # class Binary
      end # class Relation
    end # module Generator
  end # module SQL
end # module Axiom
