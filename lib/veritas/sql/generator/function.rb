# encoding: utf-8

module Veritas
  module SQL
    module Generator

      # Generates an SQL statement for a function expression
      module Function
        include Attribute, Literal

      private

        # Return the SQL for a umary prefix operation
        #
        # @param [#to_s] operator
        #
        # @param [Function::Unary] function
        #
        # @return [#to_s]
        #
        # @api private
        def unary_prefix_operation_sql(operator, function)
          "#{operator} (#{dispatch(function.operand)})"
        end

        # Return the SQL for a binary prefix operation
        #
        # @param [#to_s] operator
        #
        # @param [Function::Binary] function
        #
        # @return [#to_s]
        #
        # @api private
        def binary_prefix_operation_sql(operator, function)
          "#{operator} (#{dispatch(function.left)}, #{dispatch(function.right)})"
        end

        # Return the SQL for a binary infix operation
        #
        # @param [#to_s] operator
        #
        # @param [Function::Binary] function
        #
        # @return [#to_s]
        #
        # @api private
        def binary_infix_operation_sql(operator, function)
          "#{dispatch(function.left)} #{operator} #{dispatch(function.right)}"
        end

      end # module Function
    end # module Generator
  end # module SQL
end # module Veritas
