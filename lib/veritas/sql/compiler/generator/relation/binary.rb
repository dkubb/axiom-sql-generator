module Veritas
  module SQL
    module Compiler
      module Generator
        class Relation

          # Generates an SQL statement for a Binary relation
          class Binary < Relation
            include Attribute

            # Visit an Join
            #
            # @param [Algebra::Join] join
            #
            # @return [self]
            #
            # @api private
            def visit_veritas_algebra_join(join)
              @left    = operand_dispatch(join.left)
              @right   = operand_dispatch(join.right)
              @columns = columns_for(join)
              @name    = [ @left.name, @right.name ].uniq.join('_').freeze
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
            def to_inner
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
              "SELECT #{columns} FROM" \
              " (#{@left.to_inner}) AS #{visit_identifier('left')}" \
              " NATURAL JOIN" \
              " (#{@right.to_inner}) AS #{visit_identifier('right')}"
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
              generator_class = case visitable
                when Veritas::Relation::Operation::Set
                  Set
                when Veritas::Relation::Operation::Binary
                  self.class
                else
                  Unary
              end
              generator_class.new.visit(visitable)
            end

          end # class Binary
        end # class Relation
      end # module Generator
    end # module Compiler
  end # module SQL
end # module Veritas
