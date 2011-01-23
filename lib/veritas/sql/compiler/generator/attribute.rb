module Veritas
  module SQL
    module Compiler
      class Generator < Visitor

        # Generates an SQL statement for an attribute
        module Attribute
          include Identifier

          # Visit an Attribute
          #
          # @param [Attribute] attribute
          #
          # @return [#to_s]
          #
          # @api private
          def visit_veritas_attribute(attribute)
            "#{visit_identifier(@base_relation)}.#{visit_identifier(attribute.name)}"
          end

        end # module Attribute
      end # class Generator
    end # module Compiler
  end # module SQL
end # module Veritas
