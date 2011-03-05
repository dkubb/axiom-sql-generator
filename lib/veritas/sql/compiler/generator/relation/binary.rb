module Veritas
  module SQL
    module Compiler
      module Generator
        class Relation

          # Generates an SQL statement for a Binary relation
          class Binary < Relation
            include Attribute

            JOIN           = 'NATURAL JOIN'.freeze
            PRODUCT        = 'CROSS JOIN'.freeze
            DISPATCH_TYPES = [
              Veritas::Relation::Operation::Set,
              Veritas::Relation::Operation::Binary,
              Veritas::Relation::Operation::Unary,
              Veritas::BaseRelation,
            ].freeze

            # Return the subquery for the generator and identifier
            #
            # @param [#to_subquery] generator
            #
            # @return [#to_s]
            #
            # @api private
            def self.subquery(generator, *)
              generator.kind_of?(Base) ? generator.to_subquery : super
            end

            # Visit an Join
            #
            # @param [Algebra::Join] join
            #
            # @return [self]
            #
            # @api private
            def visit_veritas_algebra_join(join)
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
            def visit_veritas_algebra_product(product)
              set_operation(PRODUCT)
              set_columns(product)
              set_operands(product)
              set_name
              self
            end

            # Return the SQL for the binary relation
            #
            # @example
            #   sql = binary_relation.to_s
            #
            # @return [#to_s]
            #
            # @api public
            def to_s
              generate_sql(@columns)
            end

            # Return the SQL suitable for an inner query
            #
            # @return [#to_s]
            #
            # @api private
            def to_subquery
              generate_sql('*')
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
              return EMPTY_STRING unless visited?
              "SELECT #{columns} FROM #{left_subquery} #{@operation} #{right_subquery}"
            end

            # Return the left subquery
            #
            # @return [#to_s]
            #
            # @api private
            def left_subquery
              self.class.subquery(@left, 'left')
            end

            # Return the right subquery
            #
            # @return [#to_s]
            #
            # @api private
            def right_subquery
              self.class.subquery(@right, 'right')
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

            # Return a list of columns in a header
            #
            # @param [Veritas::Relation] relation
            #
            # @return [#to_s]
            #
            # @api private
            def columns_for(relation)
              relation.header.map { |attribute| dispatch(attribute) }.join(SEPARATOR)
            end

            # Dispatch the operand to the proper handler
            #
            # @param [Visitable] visitable
            #
            # @return [Generator]
            #
            # @api private
            def operand_dispatch(visitable)
              visitor_class = DISPATCH_TYPES.detect { |klass| visitable.kind_of?(klass) }
              send(self.class.handler_for(visitor_class), visitable)
            end

            # Visit a Binary Relation
            #
            # @param [Veritas::Relation::Operation::Binary] binary
            #
            # @return [Relation::Binary]
            #
            # @api private
            def visit_veritas_relation_operation_binary(binary)
              self.class::Binary.new.visit(binary)
            end

            # Visit a Set Relation
            #
            # @param [Veritas::Relation::Operation::Set] set
            #
            # @return [Relation::Set]
            #
            # @api private
            def visit_veritas_relation_operation_set(set)
              self.class::Set.new.visit(set)
            end

            # Visit a Unary Relation
            #
            # @param [Veritas::Relation::Operation::Unary] unary
            #
            # @return [Relation::Unary]
            #
            # @api private
            def visit_veritas_relation_operation_unary(unary)
              self.class::Unary.new.visit(unary)
            end

            # Visit a Base Relation
            #
            # @param [Veritas::BaseRelation] base_relation
            #
            # @return [Relation::Base]
            #
            # @api private
            def visit_veritas_base_relation(base_relation)
              self.class::Base.new.visit(base_relation)
            end

            # Generates an SQL statement for base relation binary operands
            class Base < Relation
              include Identifier

              # Visit a Base Relation
              #
              # @param [Veritas::BaseRelation] base_relation
              #
              # @return [self]
              #
              # @api private
              def visit_veritas_base_relation(base_relation)
                @name = base_relation.name
                @from = visit_identifier(@name)
                self
              end

              # Return the SQL suitable for an inner query
              #
              # @return [#to_s]
              #
              # @api private
              def to_subquery
                visited? ? @from : EMPTY_STRING
              end

            end # class Base
          end # class Binary
        end # class Relation
      end # module Generator
    end # module Compiler
  end # module SQL
end # module Veritas
