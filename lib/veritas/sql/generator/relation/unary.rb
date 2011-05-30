# encoding: utf-8

module Veritas
  module SQL
    module Generator
      class Relation

        # Generates an SQL statement for a unary relation
        class Unary < Relation
          extend Aliasable
          include Direction,
                  Literal,
                  Function::Aggregate,
                  Function::Connective,
                  Function::Predicate,
                  Function::Proposition,
                  Function::String,
                  Function::Numeric

          inheritable_alias(:visit_veritas_relation_operation_reverse => :visit_veritas_relation_operation_order)

          DISTINCT    = 'DISTINCT '.freeze
          NO_ROWS     = ' HAVING FALSE'.freeze
          ANY_ROWS    = ' HAVING COUNT (*) > 0'
          COLLAPSIBLE = {
            Algebra::Summarization                => Set[                                                                                                                                                                                                                                                               ].freeze,
            Algebra::Projection                   => Set[ Algebra::Projection,                                      Algebra::Restriction,                                                                                                                                                                               ].freeze,
            Algebra::Extension                    => Set[ Algebra::Projection,                     Algebra::Rename, Algebra::Restriction, Algebra::Summarization, Veritas::Relation::Operation::Order, Veritas::Relation::Operation::Reverse, Veritas::Relation::Operation::Offset, Veritas::Relation::Operation::Limit ].freeze,
            Algebra::Rename                       => Set[ Algebra::Projection,                                      Algebra::Restriction,                         Veritas::Relation::Operation::Order, Veritas::Relation::Operation::Reverse, Veritas::Relation::Operation::Offset, Veritas::Relation::Operation::Limit ].freeze,
            Algebra::Restriction                  => Set[ Algebra::Projection,                                                                                    Veritas::Relation::Operation::Order, Veritas::Relation::Operation::Reverse,                                                                           ].freeze,
            Veritas::Relation::Operation::Order   => Set[ Algebra::Projection, Algebra::Extension, Algebra::Rename, Algebra::Restriction, Algebra::Summarization, Veritas::Relation::Operation::Order, Veritas::Relation::Operation::Reverse,                                                                           ].freeze,
            Veritas::Relation::Operation::Reverse => Set[ Algebra::Projection, Algebra::Extension, Algebra::Rename, Algebra::Restriction, Algebra::Summarization, Veritas::Relation::Operation::Order, Veritas::Relation::Operation::Reverse,                                                                           ].freeze,
            Veritas::Relation::Operation::Offset  => Set[ Algebra::Projection, Algebra::Extension, Algebra::Rename, Algebra::Restriction, Algebra::Summarization, Veritas::Relation::Operation::Order, Veritas::Relation::Operation::Reverse,                                                                           ].freeze,
            Veritas::Relation::Operation::Limit   => Set[ Algebra::Projection, Algebra::Extension, Algebra::Rename, Algebra::Restriction, Algebra::Summarization, Veritas::Relation::Operation::Order, Veritas::Relation::Operation::Reverse, Veritas::Relation::Operation::Offset,                                     ].freeze,
          }.freeze

          # Initialize a Unary relation SQL generator
          #
          # @return [undefined]
          #
          # @api private
          def initialize
            super
            @scope = ::Set.new
          end

          # Visit a Base Relation
          #
          # @param [Relation::Base] base_relation
          #
          # @return [self]
          #
          # @api private
          def visit_veritas_relation_base(base_relation)
            @name    = base_relation.name
            @from    = visit_identifier(@name)
            @header  = base_relation.header
            @columns = columns_for(base_relation)
            self
          end

          # Visit a Projection
          #
          # @param [Algebra::Projection] projection
          #
          # @return [self]
          #
          # @api private
          def visit_veritas_algebra_projection(projection)
            @from     = subquery_for(projection)
            @distinct = DISTINCT
            @header   = projection.header
            @columns  = columns_for(projection)
            scope_query(projection)
            self
          end

          # Visit an Extension
          #
          # @param [Algebra::Extension] extension
          #
          # @return [self]
          #
          # @api private
          def visit_veritas_algebra_extension(extension)
            @from      = subquery_for(extension)
            @header    = extension.header
            @columns ||= columns_for(extension.operand)
            add_extensions(extension.extensions)
            scope_query(extension)
            self
          end

          # Visit a Rename
          #
          # @param [Algebra::Rename] rename
          #
          # @return [self]
          #
          # @api private
          def visit_veritas_algebra_rename(rename)
            @from    = subquery_for(rename)
            @header  = rename.header
            @columns = columns_for(rename.operand, rename.aliases.to_hash)
            scope_query(rename)
            self
          end

          # Visit a Restriction
          #
          # @param [Algebra::Restriction] restriction
          #
          # @return [self]
          #
          # @api private
          def visit_veritas_algebra_restriction(restriction)
            @from      = subquery_for(restriction)
            @where     = " WHERE #{dispatch(restriction.predicate)}"
            @header    = restriction.header
            @columns ||= columns_for(restriction)
            scope_query(restriction)
            self
          end

          # Visit a Summarization
          #
          # @param [Algebra::Summarization] summarization
          #
          # @return [self]
          #
          # @api private
          def visit_veritas_algebra_summarization(summarization)
            summarize_per = summarization.summarize_per
            @from         = subquery_for(summarization)
            @header       = summarization.header
            @columns      = columns_for(summarize_per)
            summarize_per(summarize_per)
            group_by_columns
            add_extensions(summarization.summarizers)
            scope_query(summarization)
            self
          end

          # Visit an Order
          #
          # @param [Relation::Operation::Order] order
          #
          # @return [self]
          #
          # @api private
          def visit_veritas_relation_operation_order(order)
            @from      = subquery_for(order)
            @order     = " ORDER BY #{order_for(order.directions)}"
            @header    = order.header
            @columns ||= columns_for(order)
            scope_query(order)
            self
          end

          # Visit a Limit
          #
          # @param [Relation::Operation::Limit] limit
          #
          # @return [self]
          #
          # @api private
          def visit_veritas_relation_operation_limit(limit)
            @from      = subquery_for(limit)
            @limit     = " LIMIT #{limit.limit}"
            @header    = limit.header
            @columns ||= columns_for(limit)
            scope_query(limit)
            self
          end

          # Visit an Offset
          #
          # @param [Relation::Operation::Offset] offset
          #
          # @return [self]
          #
          # @api private
          def visit_veritas_relation_operation_offset(offset)
            @from      = subquery_for(offset)
            @offset    = " OFFSET #{offset.offset}"
            @header    = offset.header
            @columns ||= columns_for(offset)
            scope_query(offset)
            self
          end

        private

          # Generate the SQL using the supplied columns
          #
          # @param [String] columns
          #
          # @return [#to_s]
          #
          # @api private
          def generate_sql(columns)
            [ "SELECT #{columns} FROM #{@from}", @where, @group, @having, @order, @limit, @offset ].join
          end

          # Return the columns to use in a query
          #
          # @return [#to_s]
          #
          # @api private
          def query_columns
            explicit_columns
          end

          # Return the columns to use in a subquery
          #
          # @return [#to_s]
          #
          # @api private
          def subquery_columns
            explicit_columns_in_subquery? ? explicit_columns : super
          end

          # Test if the subquery should use "*" and not specify columns explicitly
          #
          # @return [Boolean]
          #
          # @api private
          def explicit_columns_in_subquery?
            @scope.include?(Algebra::Projection) ||
            @scope.include?(Algebra::Rename)     ||
            @scope.include?(Algebra::Summarization)
          end

          # Return a list of columns for ordering
          #
          # @param [DirectionSet] directions
          #
          # @return [#to_s]
          #
          # @api private
          def order_for(directions)
            directions.map { |direction| dispatch(direction) }.join(SEPARATOR)
          end

          # Summarize the operand over the provided relation
          #
          # @param [Relation] relation
          #
          # @return [undefined]
          #
          # @api private
          def summarize_per(relation)
            return if relation.eql?(TABLE_DEE)

            if    relation.eql?(TABLE_DUM)                             then summarize_per_table_dum
            elsif (generator = Binary.visit(relation)).name.eql?(name) then summarize_per_subset
            else
              summarize_per_relation(generator)
            end
          end

          # Summarize the operand using table dee
          #
          # @return [undefined]
          #
          # @api private
          def summarize_per_table_dum
            @having = NO_ROWS
          end

          # Summarize the operand using a subset
          #
          # @return [undefined]
          #
          # @api private
          def summarize_per_subset
            @having = ANY_ROWS
          end

          # Summarize the operand using another relation
          #
          # @return [undefined]
          #
          # @api private
          def summarize_per_relation(generator)
            @from = "#{generator.to_subquery} AS #{visit_identifier(generator.name)} NATURAL LEFT JOIN #{@from}"
          end

          # Group by the columns
          #
          # @return [undefined]
          #
          # @api private
          def group_by_columns
            @group = " GROUP BY #{column_list_for(@columns)}" if @columns.any?
          end

          # Return an expression that can be used for the FROM
          #
          # @param [Relation] relation
          #
          # @return [#to_s]
          #
          # @api private
          def subquery_for(relation)
            operand  = relation.operand
            subquery = dispatch(operand)
            if collapse_subquery_for?(relation)
              @from
            else
              aliased_subquery(subquery)
            end
          end

          # Add the operand to the current scope
          #
          # @param [Relation] operand
          #
          # @return [undefined]
          #
          # @api private
          def scope_query(operand)
            @scope << operand.class
          end

          # Test if the relation should be collapsed
          #
          # @param [Relation] relation
          #
          # @return [#to_s]
          #
          # @api private
          def collapse_subquery_for?(relation)
            @scope.subset?(COLLAPSIBLE.fetch(relation.class))
          end

          # Returns an aliased subquery
          #
          # @param [#to_s] subquery
          #
          # @return [#to_s]
          #
          # @api private
          def aliased_subquery(subquery)
            "#{subquery.to_subquery} AS #{visit_identifier(subquery.name)}"
          ensure
            reset_query_state
          end

          # Visit a Binary Relation
          #
          # @param [Relation::Operation::Binary] set
          #
          # @return [Relation::Binary]
          #
          # @api private
          def visit_veritas_relation_operation_binary(binary)
            generator = self.class.visit(binary)
            @name     = generator.name
            @from     = aliased_subquery(generator)
            generator
          end

          # Reset the query state
          #
          # @return [undefined]
          #
          # @api private
          def reset_query_state
            @scope.clear
            @extensions.clear
            @distinct = @columns = @where = @order = @limit = @offset = @group = @having = nil
          end

        end # class Unary
      end # class Relation
    end # module Generator
  end # module SQL
end # module Veritas
