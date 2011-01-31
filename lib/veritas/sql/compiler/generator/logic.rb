module Veritas
  module SQL
    module Compiler
      class Generator < Visitor

        # Generates an SQL statement for a logic expression
        module Logic
          include Attribute
          include Literal

          EQUAL_TO                 = ' = '.freeze
          EQUAL_TO_NULL            = ' IS '.freeze
          NOT_EQUAL_TO             = ' <> '.freeze
          NOT_EQUAL_TO_NULL        = ' IS NOT '.freeze
          GREATER_THAN             = ' > '.freeze
          GREATER_THAN_OR_EQUAL_TO = ' >= '.freeze
          LESS_THAN                = ' < '.freeze
          LESS_THAN_OR_EQUAL_TO    = ' <= '.freeze
          IN                       = ' IN '.freeze
          NOT_IN                   = ' NOT IN '.freeze
          BETWEEN                  = ' BETWEEN '.freeze
          NOT_BETWEEN              = ' NOT BETWEEN '.freeze
          AND                      = ' AND '.freeze
          OR                       = ' OR '.freeze
          MATCH_ALL                = '1 = 1'.freeze
          MATCH_NONE               = '1 = 0'.freeze
          EMPTY_ARRAY              = [].freeze

          # Visit an Equality predicate
          #
          # @param [Logic::Predicate::Equality] equality
          #
          # @return [#to_s]
          #
          # @api private
          def visit_veritas_logic_predicate_equality(equality)
            binary_operation_sql(equality.right.nil? ? EQUAL_TO_NULL : EQUAL_TO, equality)
          end

          # Visit an Inequality predicate
          #
          # @param [Logic::Predicate::Inequality] inequality
          #
          # @return [#to_s]
          #
          # @api private
          def visit_veritas_logic_predicate_inequality(inequality)
            expressions = inequality_expressions(inequality)
            expressions.one? ? expressions.first : "(#{expressions.join(OR)})"
          end

          # Visit an GreaterThan predicate
          #
          # @param [Logic::Predicate::GreaterThan] greater_than
          #
          # @return [#to_s]
          #
          # @api private
          def visit_veritas_logic_predicate_greater_than(greater_than)
            binary_operation_sql(GREATER_THAN, greater_than)
          end

          # Visit an GreaterThanOrEqualTo predicate
          #
          # @param [Logic::Predicate::GreaterThanOrEqualTo] greater_than_or_equal_to
          #
          # @return [#to_s]
          #
          # @api private
          def visit_veritas_logic_predicate_greater_than_or_equal_to(greater_than_or_equal_to)
            binary_operation_sql(GREATER_THAN_OR_EQUAL_TO, greater_than_or_equal_to)
          end

          # Visit an LessThan predicate
          #
          # @param [Logic::Predicate::LessThan] less_than
          #
          # @return [#to_s]
          #
          # @api private
          def visit_veritas_logic_predicate_less_than(less_than)
            binary_operation_sql(LESS_THAN, less_than)
          end

          # Visit an LessThanOrEqualTo predicate
          #
          # @param [Logic::Predicate::LessThanOrEqualTo] less_than_or_equal_to
          #
          # @return [#to_s]
          #
          # @api private
          def visit_veritas_logic_predicate_less_than_or_equal_to(less_than_or_equal_to)
            binary_operation_sql(LESS_THAN_OR_EQUAL_TO, less_than_or_equal_to)
          end

          # Visit an Inclusion predicate
          #
          # @param [Logic::Predicate::Inclusion] inclusion
          #
          # @return [#to_s]
          #
          # @api private
          def visit_veritas_logic_predicate_inclusion(inclusion)
            case inclusion.right
              when Range       then range_inclusion_sql(inclusion)
              when EMPTY_ARRAY then MATCH_NONE
              else
                binary_operation_sql(IN, inclusion)
            end
          end

          # Visit an Exclusion predicate
          #
          # @param [Logic::Predicate::Exclusion] exclusion
          #
          # @return [#to_s]
          #
          # @api private
          def visit_veritas_logic_predicate_exclusion(exclusion)
            case exclusion.right
              when Range       then range_exclusion_sql(exclusion)
              when EMPTY_ARRAY then MATCH_ALL
              else
                binary_operation_sql(NOT_IN, exclusion)
            end
          end

          # Visit an Conjunction connective
          #
          # @param [Logic::Connective::Conjunction] conjunction
          #
          # @return [#to_s]
          #
          # @api private
          def visit_veritas_logic_connective_conjunction(conjunction)
            binary_connective_sql(AND, conjunction)
          end

          # Visit an Disjunction connective
          #
          # @param [Logic::Connective::Disjunction] disjunction
          #
          # @return [#to_s]
          #
          # @api private
          def visit_veritas_logic_connective_disjunction(disjunction)
            binary_connective_sql(OR, disjunction)
          end

          # Visit an Negation connective
          #
          # @param [Logic::Connective::Negation] negation
          #
          # @return [#to_s]
          #
          # @api private
          def visit_veritas_logic_connective_negation(negation)
            "NOT #{dispatch negation.operand}"
          end

          # Visit a True proposition
          #
          # @param [Logic::Proposition::True] _true
          #
          # @return [#to_s]
          #
          # @api private
          def visit_veritas_logic_proposition_true(_true)
            MATCH_ALL
          end

          # Visit a False proposition
          #
          # @param [Logic::Proposition::False] _false
          #
          # @return [#to_s]
          #
          # @api private
          def visit_veritas_logic_proposition_false(_false)
            MATCH_NONE
          end

        private

          # Return the SQL for an Inclusion using a Range
          #
          # @param [Logic::Predicate::Inclusion] predicate
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
          # @param [Logic::Predicate::Exclusion] exclusion
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
          # @param [Logic::Predicate::Inclusion] inclusion
          #
          # @return [#to_s]
          #
          # @api private
          def exclusive_range_inclusion_sql(inclusion)
            left  = new_from_enumerable_predicate(Veritas::Logic::Predicate::GreaterThanOrEqualTo, inclusion, :first)
            right = new_from_enumerable_predicate(Veritas::Logic::Predicate::LessThan,             inclusion, :last)
            dispatch left.and(right)
          end

          # Return the SQL for an Exclusion using an exclusive Range
          #
          # @param [Logic::Predicate::Exclusion] exclusion
          #
          # @return [#to_s]
          #
          # @api private
          def exclusive_range_exclusion_sql(exclusion)
            left  = new_from_enumerable_predicate(Veritas::Logic::Predicate::LessThan,             exclusion, :first)
            right = new_from_enumerable_predicate(Veritas::Logic::Predicate::GreaterThanOrEqualTo, exclusion, :last)
            dispatch left.or(right)
          end

          # Instantiate a new Predicate object from an Enumerable Predicate
          #
          # @param [Class<Logic::Predicate>] klass
          #   the type of predicate to create
          # @param [Logic::Predicate::Enumerable] predicate
          #   the enumerable predicate
          # @param [Symbol] method
          #   the method to call on the right operand of the predicate
          # @return [Logic::Predicate]
          #
          # @api private
          def new_from_enumerable_predicate(klass, predicate, method)
            klass.new(predicate.left, predicate.right.send(method))
          end

          # Return the expressions for an inequality
          #
          # @param [Logic::Predicate::Inequality] inequality
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
          # @param [Logic::Predicate::Inequality] inequality
          #
          # @return [#to_s]
          #
          # @api private
          def inequality_sql(inequality)
            binary_operation_sql(inequality.right.nil? ? NOT_EQUAL_TO_NULL : NOT_EQUAL_TO, inequality)
          end

          # Return the SQL for a Binary Connective
          #
          # @param [#to_s] operator
          #
          # @param [Logic::Connective::Binary] binary_connective
          #
          # @return [#to_s]
          #
          # @api private
          def binary_connective_sql(operator, binary_connective)
            "(#{binary_operation_sql(operator, binary_connective)})"
          end

          # Return the SQL for a predicate
          #
          # @param [#to_s] operator
          #
          # @param [Logic::Predicate] predicate
          #
          # @return [#to_s]
          #
          # @api private
          def binary_operation_sql(operator, predicate)
            "#{dispatch(predicate.left)}#{operator}#{dispatch(predicate.right)}"
          end

          # Return the SQL for an operation using an inclusive Range
          #
          # @param [#to_s] operator
          #
          # @param [Logic::Predicate::Enumerable] predicate
          #
          # @return [#to_s]
          #
          # @api private
          def inclusive_range_sql(operator, predicate)
            right = predicate.right
            "#{dispatch(predicate.left)}#{operator}#{dispatch(right.first)}#{AND}#{dispatch(right.last)}"
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
            operand.respond_to?(:required?) && !operand.required?
          end

        end # module Logic
      end # class Generator
    end # module Compiler
  end # module SQL
end # module Veritas
