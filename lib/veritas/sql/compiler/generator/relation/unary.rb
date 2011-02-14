module Veritas
  module SQL
    module Compiler
      module Generator
        class Relation

          # Generates an SQL statement for a unary relation
          class Unary < Relation
            include Attribute
            include Direction
            include Literal
            include Logic
            extend Aliasable

            inheritable_alias(:visit_veritas_relation_operation_reverse => :visit_veritas_relation_operation_order)

            DISTINCT     = 'DISTINCT '.freeze
            SEPARATOR    = ', '.freeze
            COLLAPSIBLE  = {
              Algebra::Projection                   => Set[ BaseRelation, Algebra::Projection, Algebra::Restriction,                                                                                                                                                                        ].freeze,
              Algebra::Restriction                  => Set[ BaseRelation, Algebra::Projection,                       Veritas::Relation::Operation::Order, Veritas::Relation::Operation::Reverse,                                                                                            ].freeze,
              Veritas::Relation::Operation::Order   => Set[ BaseRelation, Algebra::Projection, Algebra::Restriction, Veritas::Relation::Operation::Order, Veritas::Relation::Operation::Reverse,                                                                            Algebra::Rename ].freeze,
              Veritas::Relation::Operation::Reverse => Set[ BaseRelation, Algebra::Projection, Algebra::Restriction, Veritas::Relation::Operation::Order, Veritas::Relation::Operation::Reverse,                                                                            Algebra::Rename ].freeze,
              Veritas::Relation::Operation::Offset  => Set[ BaseRelation, Algebra::Projection, Algebra::Restriction, Veritas::Relation::Operation::Order, Veritas::Relation::Operation::Reverse,                                                                            Algebra::Rename ].freeze,
              Veritas::Relation::Operation::Limit   => Set[ BaseRelation, Algebra::Projection, Algebra::Restriction, Veritas::Relation::Operation::Order, Veritas::Relation::Operation::Reverse, Veritas::Relation::Operation::Offset,                                      Algebra::Rename ].freeze,
              Algebra::Rename                       => Set[ BaseRelation, Algebra::Projection, Algebra::Restriction, Veritas::Relation::Operation::Order, Veritas::Relation::Operation::Reverse, Veritas::Relation::Operation::Offset, Veritas::Relation::Operation::Limit                  ].freeze,
            }.freeze

            # Initialize a Unary relation SQL generator
            #
            # @return [undefined]
            #
            # @api private
            def initialize
              super
              @scope = Set.new
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
              @columns = columns_for(base_relation.header)
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
              @from     = inner_query_for(projection)
              @distinct = DISTINCT
              @columns  = columns_for(projection.header)
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
              @from    = inner_query_for(rename)
              @columns = columns_for(rename.operand.header, rename.aliases.to_hash)
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
              @from      = inner_query_for(restriction)
              @where     = dispatch(restriction.predicate)
              @columns ||= columns_for(restriction.header)
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
              @from      = inner_query_for(order)
              @order     = order_for(order.directions)
              @columns ||= columns_for(order.header)
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
              @from      = inner_query_for(limit)
              @limit     = limit.limit
              @columns ||= columns_for(limit.header)
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
              @from      = inner_query_for(offset)
              @offset    = offset.offset
              @columns ||= columns_for(offset.header)
              scope_query(offset)
              self
            end

            # Visit a Binary Relation
            #
            # @param [Relation::Operation::Binary] binary
            #
            # @return [BinaryRelation]
            #
            # @api private
            def visit_veritas_relation_operation_binary(binary)
              generator = BinaryRelation.new.visit(binary)
              @name     = generator.name
              @from     = "(#{generator.to_inner}) AS #{visit_identifier(@name)}"
              @columns  = columns_for(binary.header)
              generator
            end

            # Return the SQL for the visitable object
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

            # Return the SQL suitable for an inner query
            #
            # @return [#to_s]
            #
            # @api private
            def to_inner
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
            # @param [Header] header
            #
            # @param [#[]] aliases
            #   optional aliases for the columns
            #
            # @return [#to_s]
            #
            # @api private
            def columns_for(header, aliases = {})
              header.map { |attribute| column_for(attribute, aliases) }.join(SEPARATOR)
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
              "#{column} AS #{visit_identifier alias_attribute.name}"
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
            def inner_query_for(relation)
              operand     = relation.operand
              inner_query = dispatch(operand)
              if collapse_inner_query_for?(relation)
                @from
              else
                aliased_inner_query(inner_query)
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
            def collapse_inner_query_for?(relation)
              @scope.subset?(COLLAPSIBLE.fetch(relation.class))
            end

            # Returns an aliased inner query
            #
            # @param [#to_s] inner_query
            #
            # @return [#to_s]
            #
            # @api private
            def aliased_inner_query(inner_query)
              "(#{inner_query.to_inner}) AS #{visit_identifier(@name)}"
            ensure
              reset_query_state
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
