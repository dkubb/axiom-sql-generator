# encoding: utf-8

module Veritas
  module SQL
    module Generator
      class Relation

        # Generates an SQL statement for an insertion
        class Insertion < Set
          extend Aliasable

          inheritable_alias(:to_subquery => :to_s)

          # Visit an Insertion
          #
          # @param [Relation::Operation::Insertion]
          #
          # @return [self]
          #
          # @api private
          def visit_veritas_relation_operation_insertion(insertion)
            @header = insertion.header.reject(&:key?)
            set_columns(insertion)
            set_operands(insertion)
            set_returning(insertion)
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
            sql = "INSERT INTO #{@name} #{column_list} #{@right}"
            sql << " RETURNING #{@returning}" if @returning
            sql
          end

          # Generate the list of columns to insert into
          #
          # @return [#to_s]
          #
          # @api private
          def column_list
            Generator.parenthesize!(column_list_for(@columns))
          end

          # @api private
          def set_operands(relation)
            if relation.right.materialized?
              normalized = self.class.normalize_operand_headers(relation)

              util   = self.class
              left   = normalized.left
              right  = normalized.right
              header = left.header.reject(&:key?)

              @left  = util.visit(left.class.new(left.name, header))
              @right = util.visit(right.project(header).materialize)
            else
              super
            end
          end

          # @api private
          def set_returning(relation)
            keys       = relation.header.select(&:key?)
            @returning = column_list_for(@columns, keys) if keys.any?
          end

          # Set the name using the left operands' name
          #
          # @return [undefined]
          #
          # @api private
          def set_name
            @name = @left.name
          end

        end # class Insertion
      end # class Relation
    end # module Generator
  end # module SQL
end # module Veritas
