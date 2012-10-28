# encoding: utf-8

module Veritas
  module SQL
    module Generator
      class Relation

        # Generates an SQL statement for materialized relation
        class Materialized < Relation
          include Literal

          # Visit a Materialized relation
          #
          # @param [Relation::Materialized] materialized
          #
          # @return [self]
          #
          # @api private
          def visit_veritas_relation_materialized(materialized)
            @values = materialized.map do |tuple|
              Generator.parenthesize!(
                tuple.to_ary.map { |value| dispatch(value) }.join(', ')
              )
            end
            self
          end

          # Test if a visitable object has been visited
          #
          # @example
          #   visitor.visited?  # true or false
          #
          # @return [Boolean]
          #
          # @api public
          def visited?
            instance_variable_defined?(:@values)
          end

        private

          # Generate the SQL for the materialized relation
          #
          # @return [#to_s]
          #
          # @api private
          def generate_sql(*)
            return EMPTY_STRING unless visited?
            if @values.empty?
              'SELECT 0 LIMIT 0'  # no values
            else
              "VALUES #{@values.join(', ')}"
            end
          end

        end # class Materialized
      end # class Relation
    end # module Generator
  end # module SQL
end # module Veritas
