# encoding: utf-8

module Axiom
  module SQL
    module Generator

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
        def visit_axiom_attribute(attribute)
          visit_identifier(attribute.name)
        end

      end # module Attribute
    end # module Generator
  end # module SQL
end # module Axiom
