# encoding: utf-8

module Axiom
  module SQL
    module Generator
      class Relation

        # Generates an SQL statement for an insertion
        class Insertion < Set
          extend Aliasable

          inheritable_alias(to_subquery: :to_s)

          # Visit an Insertion
          #
          # @param [Relation::Operation::Insertion] insertion
          #
          # @return [self]
          #
          # @api private
          def visit_axiom_relation_operation_insertion(insertion)
            @header = insertion.header
            set_columns(insertion)
            set_operands(insertion)
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
            "INSERT INTO #{@name} #{column_list} #{@right}"
          end

          # Generate the list of columns to insert into
          #
          # @return [#to_s]
          #
          # @api private
          def column_list
            Generator.parenthesize!(column_list_for(@columns))
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
end # module Axiom
