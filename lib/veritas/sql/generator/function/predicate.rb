# encoding: utf-8

module Veritas
  module SQL
    module Generator
      module Function

        # Generates an SQL statement for a predicate function
        module Predicate
          include Function

          EQUAL_TO                 = '='.freeze
          EQUAL_TO_NULL            = 'IS'.freeze
          NOT_EQUAL_TO             = '<>'.freeze
          NOT_EQUAL_TO_NULL        = 'IS NOT'.freeze
          GREATER_THAN             = '>'.freeze
          GREATER_THAN_OR_EQUAL_TO = '>='.freeze
          LESS_THAN                = '<'.freeze
          LESS_THAN_OR_EQUAL_TO    = '<='.freeze
          IN                       = 'IN'.freeze
          NOT_IN                   = 'NOT IN'.freeze
          BETWEEN                  = 'BETWEEN'.freeze
          NOT_BETWEEN              = 'NOT BETWEEN'.freeze
          EMPTY_ARRAY              = [].freeze

          # Visit an Equality predicate
          #
          # @param [Function::Predicate::Equality] equality
          #
          # @return [#to_s]
          #
          # @api private
          def visit_veritas_function_predicate_equality(equality)
            binary_infix_operation_sql(equality.right.nil? ? EQUAL_TO_NULL : EQUAL_TO, equality)
          end

          # Visit an Inequality predicate
          #
          # @param [Function::Predicate::Inequality] inequality
          #
          # @return [#to_s]
          #
          # @api private
          def visit_veritas_function_predicate_inequality(inequality)
            expressions = inequality_expressions(inequality)
            expressions.one? ? expressions.first : Generator.parenthesize!(expressions.join(' OR '))
          end

          # Visit an GreaterThan predicate
          #
          # @param [Function::Predicate::GreaterThan] greater_than
          #
          # @return [#to_s]
          #
          # @api private
          def visit_veritas_function_predicate_greater_than(greater_than)
            binary_infix_operation_sql(GREATER_THAN, greater_than)
          end

          # Visit an GreaterThanOrEqualTo predicate
          #
          # @param [Function::Predicate::GreaterThanOrEqualTo] greater_than_or_equal_to
          #
          # @return [#to_s]
          #
          # @api private
          def visit_veritas_function_predicate_greater_than_or_equal_to(greater_than_or_equal_to)
            binary_infix_operation_sql(GREATER_THAN_OR_EQUAL_TO, greater_than_or_equal_to)
          end

          # Visit an LessThan predicate
          #
          # @param [Function::Predicate::LessThan] less_than
          #
          # @return [#to_s]
          #
          # @api private
          def visit_veritas_function_predicate_less_than(less_than)
            binary_infix_operation_sql(LESS_THAN, less_than)
          end

          # Visit an LessThanOrEqualTo predicate
          #
          # @param [Function::Predicate::LessThanOrEqualTo] less_than_or_equal_to
          #
          # @return [#to_s]
          #
          # @api private
          def visit_veritas_function_predicate_less_than_or_equal_to(less_than_or_equal_to)
            binary_infix_operation_sql(LESS_THAN_OR_EQUAL_TO, less_than_or_equal_to)
          end

          # Visit an Inclusion predicate
          #
          # @param [Function::Predicate::Inclusion] inclusion
          #
          # @return [#to_s]
          #
          # @api private
          def visit_veritas_function_predicate_inclusion(inclusion)
            case inclusion.right
            when Range       then range_inclusion_sql(inclusion)
            when EMPTY_ARRAY then FALSE
            else
              binary_infix_operation_sql(IN, inclusion)
            end
          end

          # Visit an Exclusion predicate
          #
          # @param [Function::Predicate::Exclusion] exclusion
          #
          # @return [#to_s]
          #
          # @api private
          def visit_veritas_function_predicate_exclusion(exclusion)
            case exclusion.right
            when Range       then range_exclusion_sql(exclusion)
            when EMPTY_ARRAY then TRUE
            else
              binary_infix_operation_sql(NOT_IN, exclusion)
            end
          end

        private

          # Return the SQL for an Inclusion using a Range
          #
          # @param [Function::Predicate::Inclusion] predicate
          #
          # @return [#to_s]
          #
          # @api private
          def range_inclusion_sql(inclusion)
            if inclusion.right.exclude_end?
              exclusive_range_inclusion_sql(inclusion)
            else
              inclusive_range_sql(BETWEEN, inclusion)
            end
          end

          # Return the SQL for an Exclusion using a Range
          #
          # @param [Function::Predicate::Exclusion] exclusion
          #
          # @return [#to_s]
          #
          # @api private
          def range_exclusion_sql(exclusion)
            if exclusion.right.exclude_end?
              exclusive_range_exclusion_sql(exclusion)
            else
              inclusive_range_sql(NOT_BETWEEN, exclusion)
            end
          end

          # Return the SQL for an Inclusion using an exclusive Range
          #
          # @param [Function::Predicate::Inclusion] inclusion
          #
          # @return [#to_s]
          #
          # @api private
          def exclusive_range_inclusion_sql(inclusion)
            left  = new_from_enumerable_predicate(Veritas::Function::Predicate::GreaterThanOrEqualTo, inclusion, :first)
            right = new_from_enumerable_predicate(Veritas::Function::Predicate::LessThan,             inclusion, :last)
            dispatch left.and(right)
          end

          # Return the SQL for an Exclusion using an exclusive Range
          #
          # @param [Function::Predicate::Exclusion] exclusion
          #
          # @return [#to_s]
          #
          # @api private
          def exclusive_range_exclusion_sql(exclusion)
            left  = new_from_enumerable_predicate(Veritas::Function::Predicate::LessThan,             exclusion, :first)
            right = new_from_enumerable_predicate(Veritas::Function::Predicate::GreaterThanOrEqualTo, exclusion, :last)
            dispatch left.or(right)
          end

          # Instantiate a new Predicate object from an Enumerable Predicate
          #
          # @param [Class<Function::Predicate>] klass
          #   the type of predicate to create
          # @param [Function::Predicate::Enumerable] predicate
          #   the enumerable predicate
          # @param [Symbol] method
          #   the method to call on the right operand of the predicate
          # @return [Function::Predicate]
          #
          # @api private
          def new_from_enumerable_predicate(klass, predicate, method)
            klass.new(predicate.left, predicate.right.send(method))
          end

          # Return the expressions for an inequality
          #
          # @param [Function::Predicate::Inequality] inequality
          #
          # @return [Array<#to_s>]
          #
          # @api private
          def inequality_expressions(inequality)
            expressions = [
              inequality_sql(inequality),
              optional_is_null_sql(inequality.left),
              optional_is_null_sql(inequality.right),
            ]
            expressions.compact!
            expressions
          end

          # Return the SQL for an inequality predicate
          #
          # @param [Function::Predicate::Inequality] inequality
          #
          # @return [#to_s]
          #
          # @api private
          def inequality_sql(inequality)
            binary_infix_operation_sql(inequality.right.nil? ? NOT_EQUAL_TO_NULL : NOT_EQUAL_TO, inequality)
          end

          # Return the SQL for an operation using an inclusive Range
          #
          # @param [#to_s] operator
          #
          # @param [Function::Predicate::Enumerable] predicate
          #
          # @return [#to_s]
          #
          # @api private
          def inclusive_range_sql(operator, predicate)
            right = predicate.right
            "#{dispatch(predicate.left)} #{operator} #{dispatch(right.first)} AND #{dispatch(right.last)}"
          end

          # Return SQL for an Equality with a nil value for optional attributes
          #
          # @param [Attribute] attribute
          #
          # @return [#to_sql, nil]
          #
          # @api private
          def optional_is_null_sql(attribute)
            dispatch(attribute.eq(nil)) if optional?(attribute)
          end

          # Test if the object is not required
          #
          # @param [Object] operand
          #
          # @return [Boolean]
          #
          # @api private
          def optional?(operand)
            operand.respond_to?(:required?) && ! operand.required?
          end

        end # module Predicate
      end # module Function
    end # module Generator
  end # module SQL
end # module Veritas
