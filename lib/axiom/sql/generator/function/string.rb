# encoding: utf-8

module Axiom
  module SQL
    module Generator
      module Function

        # Generates an SQL statement for a string function
        module String
          include Function

          LENGTH = 'LENGTH'.freeze

          # Visit a Length function
          #
          # @param [Function::String::Length] length
          #
          # @return [#to_s]
          #
          # @api private
          def visit_axiom_function_string_length(length)
            unary_prefix_operation_sql(LENGTH, length)
          end

        end # module String
      end # module Function
    end # module Generator
  end # module SQL
end # module Axiom
