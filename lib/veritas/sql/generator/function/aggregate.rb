# encoding: utf-8

module Veritas
  module SQL
    module Generator
      module Function

        # Generates an SQL statement for an aggregate function
        module Aggregate
          include Function

          COUNT              = 'COUNT'.freeze
          SUM                = 'SUM'.freeze
          MINIMUM            = 'MIN'.freeze
          MAXIMUM            = 'MAX'.freeze
          MEAN               = 'AVG'.freeze
          VARIANCE           = 'VAR_POP'.freeze
          STANDARD_DEVIATION = 'STDDEV_POP'.freeze

          # Visit a count aggregate function
          #
          # @param [Veritas::Aggregate::Count] count
          #
          # @return [#to_s]
          #
          # @api private
          def visit_veritas_aggregate_count(count)
            unary_prefix_operation_sql(COUNT, count)
          end

          # Visit a sum aggregate function
          #
          # @param [Veritas::Aggregate::Sum] sum
          #
          # @return [#to_s]
          #
          # @api private
          def visit_veritas_aggregate_sum(sum)
            aggregate_function_sql(SUM, sum)
          end

          # Visit a minimum aggregate function
          #
          # @param [Veritas::Aggregate::Minimum] minimum
          #
          # @return [#to_s]
          #
          # @api private
          def visit_veritas_aggregate_minimum(minimum)
            # TODO: wrap this in a coalesce operation once the default can be made sane
            unary_prefix_operation_sql(MINIMUM, minimum)
          end

          # Visit a maximum aggregate function
          #
          # @param [Veritas::Aggregate::Maximum] maximum
          #
          # @return [#to_s]
          #
          # @api private
          def visit_veritas_aggregate_maximum(maximum)
            # TODO: wrap this in a coalesce operation once the default can be made sane
            unary_prefix_operation_sql(MAXIMUM, maximum)
          end

          # Visit a mean aggregate function
          #
          # @param [Veritas::Aggregate::Mean] mean
          #
          # @return [#to_s]
          #
          # @api private
          def visit_veritas_aggregate_mean(mean)
            unary_prefix_operation_sql(MEAN, mean)
          end

          # Visit a variance aggregate function
          #
          # @param [Veritas::Aggregate::Variance] variance
          #
          # @return [#to_s]
          #
          # @api private
          def visit_veritas_aggregate_variance(variance)
            unary_prefix_operation_sql(VARIANCE, variance)
          end

          # Visit a standard deviation aggregate function
          #
          # @param [Veritas::Aggregate::StandardDeviation] standard_deviation
          #
          # @return [#to_s]
          #
          # @api private
          def visit_veritas_aggregate_standard_deviation(standard_deviation)
            unary_prefix_operation_sql(STANDARD_DEVIATION, standard_deviation)
          end

        private

          # Return the SQL
          #
          # @param [#to_s] operation
          #
          # @param [Veritas::Aggregate] aggregate
          #
          # @return [#to_s]
          #
          # @api private
          def aggregate_function_sql(operation, aggregate)
            default_when_null(
              unary_prefix_operation_sql(operation, aggregate),
              aggregate.finalize(aggregate.default)
            )
          end

          # Specify a default value when SQL expression evaluates to NULL
          #
          # @param [#to_s] sql
          #
          # @param [Visitable] default
          #
          # @return [#to_s]
          #
          # @api private
          def default_when_null(sql, default)
            "COALESCE (#{sql}, #{dispatch(default)})"
          end

        end # module Aggregate
      end # module Function
    end # module Generator
  end # module SQL
end # module Veritas
