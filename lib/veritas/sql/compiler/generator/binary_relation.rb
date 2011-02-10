module Veritas
  module SQL
    module Compiler
      class Generator < Visitor

        # Generates an SQL statement for a binary relation
        class BinaryRelation < Generator

          # Return the SQL for the visitable object
          #
          # @example
          #   sql = binary_relation.to_s
          #
          # @return [#to_s]
          #
          # @api public
          def to_s
            EMPTY_STRING
          end

        end # class BinaryRelation
      end # class Generator
    end # module Compiler
  end # module SQL
end # module Veritas
