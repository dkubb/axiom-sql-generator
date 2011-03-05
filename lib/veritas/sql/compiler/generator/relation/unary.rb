module Veritas
  module SQL
    module Compiler
      module Generator
        class Relation

          # Generates an SQL statement for a unary relation
          class Unary < Relation
            extend Aliasable
            include Attribute
            include Direction
            include Literal
            include Logic

            inheritable_alias(:visit_veritas_relation_operation_reverse => :visit_veritas_relation_operation_order)

            DISTINCT     = 'DISTINCT '.freeze
            COLLAPSIBLE  = {
              Algebra::Projection                   => Set[ Algebra::Projection, Algebra::Restriction,                                                                                                                                                                        ].freeze,
              Algebra::Restriction                  => Set[ Algebra::Projection,                       Veritas::Relation::Operation::Order, Veritas::Relation::Operation::Reverse,                                                                                            ].freeze,
              Veritas::Relation::Operation::Order   => Set[ Algebra::Projection, Algebra::Restriction, Veritas::Relation::Operation::Order, Veritas::Relation::Operation::Reverse,                                                                            Algebra::Rename ].freeze,
              Veritas::Relation::Operation::Reverse => Set[ Algebra::Projection, Algebra::Restriction, Veritas::Relation::Operation::Order, Veritas::Relation::Operation::Reverse,                                                                            Algebra::Rename ].freeze,
              Veritas::Relation::Operation::Offset  => Set[ Algebra::Projection, Algebra::Restriction, Veritas::Relation::Operation::Order, Veritas::Relation::Operation::Reverse,                                                                            Algebra::Rename ].freeze,
              Veritas::Relation::Operation::Limit   => Set[ Algebra::Projection, Algebra::Restriction, Veritas::Relation::Operation::Order, Veritas::Relation::Operation::Reverse, Veritas::Relation::Operation::Offset,                                      Algebra::Rename ].freeze,
              Algebra::Rename                       => Set[ Algebra::Projection, Algebra::Restriction, Veritas::Relation::Operation::Order, Veritas::Relation::Operation::Reverse, Veritas::Relation::Operation::Offset, Veritas::Relation::Operation::Limit                  ].freeze,
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
            # @param [BaseRelation] base_relation
            #
            # @return [self]
            #
            # @api private
            def visit_veritas_base_relation(base_relation)
              @name    = base_relation.name
              @from    = visit_identifier(@name)
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
              @columns  = columns_for(projection)
              scope_query(projection)
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
              @where     = dispatch(restriction.predicate)
              @columns ||= columns_for(restriction)
              scope_query(restriction)
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
              @order     = order_for(order.directions)
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
              @limit     = limit.limit
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
              @offset    = offset.offset
              @columns ||= columns_for(offset)
              scope_query(offset)
              self
            end

            # Return the SQL for the unary relation
            #
            # @example
            #   sql = unary_relation.to_s
            #
            # @return [#to_s]
            #
            # @api public
            def to_s
              generate_sql(@columns)
            end

            # Return the SQL suitable for an subquery
            #
            # @return [#to_s]
            #
            # @api private
            def to_subquery
              generate_sql(all_columns? ? '*' : @columns)
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
              return EMPTY_STRING unless visited?
              sql = "SELECT #{@distinct}#{columns} FROM #{@from}"
              sql << " WHERE #{@where}"    if @where
              sql << " ORDER BY #{@order}" if @order
              sql << " LIMIT #{@limit}"    if @limit
              sql << " OFFSET #{@offset}"  if @offset
              sql
            end

            # Return a list of columns in a header
            #
            # @param [Veritas::Relation] relation
            #
            # @param [#[]] aliases
            #   optional aliases for the columns
            #
            # @return [#to_s]
            #
            # @api private
            def columns_for(relation, aliases = {})
              relation.header.map { |attribute| column_for(attribute, aliases) }.join(SEPARATOR)
            end

            # Return the column for an attribute
            #
            # @param [Attribute] attribute
            #
            # @param [#[]] aliases
            #   aliases for the columns
            #
            # @return [#to_s]
            #
            # @api private
            def column_for(attribute, aliases)
              column = dispatch(attribute)
              if aliases.key?(attribute)
                alias_for(column, aliases[attribute])
              else
                column
              end
            end

            # Return the column alias for an attribute
            #
            # @param [#to_s] column
            #
            # @param [Attribute, nil] alias_attribute
            #   attribute to use for the alias
            #
            # @return [#to_s]
            #
            # @api private
            def alias_for(column, alias_attribute)
              "#{column} AS #{visit_identifier(alias_attribute.name)}"
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

            # Return an expression that can be used for the FROM
            #
            # @param [Relation] relation
            #
            # @return [#to_s]
            #
            # @api private
            def subquery_for(relation)
              operand     = relation.operand
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

            # Test if the query should use "*" and not specify columns explicitly
            #
            # @return [Boolean]
            #
            # @api private
            def all_columns?
              !@scope.include?(Algebra::Projection) && !@scope.include?(Algebra::Rename)
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
              self.class.subquery(subquery)
            ensure
              reset_query_state
            end

            # Visit a Set Relation
            #
            # @param [Relation::Operation::Set] set
            #
            # @return [Relation::Set]
            #
            # @api private
            def visit_veritas_relation_operation_set(set)
              generator_dispatch(Relation::Set, set)
            end

            # Visit a Binary Relation
            #
            # @param [Relation::Operation::Binary] set
            #
            # @return [Relation::Binary]
            #
            # @api private
            def visit_veritas_relation_operation_binary(binary)
              generator_dispatch(Relation::Binary, binary)
            end

            # Dispatches to a Relation Generator
            #
            # @param [Class<Generator::Relation>] generator_class
            #
            # @param [Veritas::Relation::Operation::Binary] binary
            #
            # @return [Generator::Relation]
            #
            # @api private
            def generator_dispatch(generator_class, binary)
              generator = generator_class.new.visit(binary)
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
              @distinct = @columns = @where = @order = @limit = @offset = nil
            end

          end # class Unary
        end # class Relation
      end # module Generator
    end # module Compiler
  end # module SQL
end # module Veritas
