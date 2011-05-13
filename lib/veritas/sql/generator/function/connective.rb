# encoding: utf-8

module Veritas
  module SQL
    module Generator
      module Function

        # Generates an SQL statement for a connective
        module Connective
          include Function

          AND = 'AND'.freeze
          OR  = 'OR'.freeze
          NOT = 'NOT'.freeze

          # Visit an Conjunction connective
          #
          # @param [Function::Connective::Conjunction] conjunction
          #
          # @return [#to_s]
          #
          # @api private
          def visit_veritas_function_connective_conjunction(conjunction)
            Generator.parenthesize!(binary_infix_operation_sql(AND, conjunction))
          end

          # Visit an Disjunction connective
          #
          # @param [Function::Connective::Disjunction] disjunction
          #
          # @return [#to_s]
          #
          # @api private
          def visit_veritas_function_connective_disjunction(disjunction)
            Generator.parenthesize!(binary_infix_operation_sql(OR, disjunction))
          end

          # Visit an Negation connective
          #
          # @param [Function::Connective::Negation] negation
          #
          # @return [#to_s]
          #
          # @api private
          def visit_veritas_function_connective_negation(negation)
            unary_prefix_operation_sql(NOT, negation)
          end

        end # module Connective
      end # module Function
    end # module Generator
  end # module SQL
end # module Veritas
