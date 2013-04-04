# encoding: utf-8

module Axiom
  module SQL
    module Generator

      # Generates an SQL statement for a direction
      module Direction
        include Attribute

        DESC = ' DESC'.freeze

        # Visit an Ascending Direction
        #
        # @param [Relation::Operation::Order::Ascending] direction
        #
        # @return [#to_s]
        #
        # @api private
        def visit_axiom_relation_operation_order_ascending(direction)
          dispatch direction.attribute
        end

        # Visit an Descending Direction
        #
        # @param [Relation::Operation::Order::Descending] direction
        #
        # @return [#to_s]
        #
        # @api private
        def visit_axiom_relation_operation_order_descending(direction)
          dispatch(direction.attribute) << DESC
        end

      end # module Direction
    end # module Generator
  end # module SQL
end # module Axiom
