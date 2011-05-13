# encoding: utf-8

module Veritas
  module SQL
    module Generator
      module Function

        # Generates an SQL statement for a numeric function
        module Numeric
          include Function

          ABSOLUTE    = 'ABS'.freeze
          ADD         = '+'.freeze
          SUBTRACT    = '-'.freeze
          MULTIPLY    = '*'.freeze
          DIVIDE      = '/'.freeze
          POWER       = 'POWER'.freeze
          MOD         = 'MOD'.freeze
          RANDOM      = 'RANDOM ()'.freeze
          SQUARE_ROOT = 'SQRT'.freeze

          # Visit an Absolute function
          #
          # @param [Function::Numeric::Absolute] absolute
          #
          # @return [#to_s]
          #
          # @api private
          def visit_veritas_function_numeric_absolute(absolute)
            unary_prefix_operation_sql(ABSOLUTE, absolute)
          end

          # Visit an Addition function
          #
          # @param [Function::Numeric::Addition] addition
          #
          # @return [#to_s]
          #
          # @api private
          def visit_veritas_function_numeric_addition(addition)
            Generator.parenthesize!(binary_infix_operation_sql(ADD, addition))
          end

          # Visit a Division function
          #
          # @param [Function::Numeric::Division] division
          #
          # @return [#to_s]
          #
          # @api private
          def visit_veritas_function_numeric_division(division)
            Generator.parenthesize!(binary_infix_operation_sql(DIVIDE, division))
          end

          # Visit a Exponentiation function
          #
          # @param [Function::Numeric::Exponentiation] exponentiation
          #
          # @return [#to_s]
          #
          # @api private
          def visit_veritas_function_numeric_exponentiation(exponentiation)
            binary_prefix_operation_sql(POWER, exponentiation)
          end

          # Visit a Modulo function
          #
          # @param [Function::Numeric::Modulo] modulo
          #
          # @return [#to_s]
          #
          # @api private
          def visit_veritas_function_numeric_modulo(modulo)
            binary_prefix_operation_sql(MOD, modulo)
          end

          # Visit a Multiplication function
          #
          # @param [Function::Numeric::Multiplication] multiplication
          #
          # @return [#to_s]
          #
          # @api private
          def visit_veritas_function_numeric_multiplication(multiplication)
            Generator.parenthesize!(binary_infix_operation_sql(MULTIPLY, multiplication))
          end

          # Visit a Random function
          #
          # @param [Function::Numeric::Random] random
          #
          # @return [#to_s]
          #
          # @api private
          def visit_veritas_function_numeric_random(_random)
            RANDOM
          end

          # Visit a Square Root function
          #
          # @param [Function::Numeric::SquareRoot] square_root
          #
          # @return [#to_s]
          #
          # @api private
          def visit_veritas_function_numeric_square_root(square_root)
            unary_prefix_operation_sql(SQUARE_ROOT, square_root)
          end

          # Visit an Addition function
          #
          # @param [Function::Numeric::Addition] subtraction
          #
          # @return [#to_s]
          #
          # @api private
          def visit_veritas_function_numeric_subtraction(subtraction)
            Generator.parenthesize!(binary_infix_operation_sql(SUBTRACT, subtraction))
          end

          # Visit an Unary Minus function
          #
          # @param [Function::Numeric::UnaryMinus] unary_minus
          #
          # @return [#to_s]
          #
          # @api private
          def visit_veritas_function_numeric_unary_minus(unary_minus)
            unary_prefix_operation_sql(SUBTRACT, unary_minus)
          end

          # Visit an Unary Plus function
          #
          # @param [Function::Numeric::UnaryPlus] unary_plus
          #
          # @return [#to_s]
          #
          # @api private
          def visit_veritas_function_numeric_unary_plus(unary_plus)
            unary_prefix_operation_sql(ADD, unary_plus)
          end

        end # module Numeric
      end # module Function
    end # module Generator
  end # module SQL
end # module Veritas
