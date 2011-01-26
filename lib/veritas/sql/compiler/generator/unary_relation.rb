module Veritas
  module SQL
    module Compiler
      class Generator < Visitor

        # Generates an SQL statement for a unary relation
        module UnaryRelation
          include Logic
          include Direction

          SEPARATOR    = ', '.freeze
          EMPTY_STRING = ''.freeze

          # Visit a Base Relation
          #
          # @param [BaseRelation] base_relation
          #
          # @return [undefined]
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
          # @return [undefined]
          #
          # @api private
          def visit_veritas_algebra_projection(projection)
            dispatch projection.operand
            @columns = columns_for(projection.header)
            self
          end

          # Visit a Rename
          #
          # @param [Algebra::Rename] rename
          #
          # @return [undefined]
          #
          # @api private
          def visit_veritas_algebra_rename(rename)
            dispatch(operand = rename.operand)
            @columns = columns_for(operand.header, rename.aliases.to_hash)
            self
          end

          # Visit a Restriction
          #
          # @param [Algebra::Restriction] restriction
          #
          # @return [undefined]
          #
          # @api private
          def visit_veritas_algebra_restriction(restriction)
            dispatch restriction.operand
            @where = dispatch restriction.predicate
            self
          end

          # Visit an Order
          #
          # @param [Relation::Operation::Order] order
          #
          # @return [undefined]
          #
          # @api private
          def visit_veritas_relation_operation_order(order)
            dispatch order.operand
            @order = order.directions.map { |direction| dispatch direction }
            self
          end

          # Visit a Limit
          #
          # @param [Relation::Operation::Limit] limit
          #
          # @return [undefined]
          #
          # @api private
          def visit_veritas_relation_operation_limit(limit)
            dispatch limit.operand
            @limit = dispatch limit.limit
            self
          end

          # Visit an Offset
          #
          # @param [Relation::Operation::Offset] offset
          #
          # @return [undefined]
          #
          # @api private
          def visit_veritas_relation_operation_offset(offset)
            dispatch offset.operand
            @offset = dispatch offset.offset
            self
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
            return EMPTY_STRING unless visited?
            sql = "SELECT DISTINCT #{@columns.join(SEPARATOR)} FROM #{@from}"
            sql << " WHERE #{@where}"                    if @where
            sql << " ORDER BY #{@order.join(SEPARATOR)}" if @order
            sql << " LIMIT #{@limit}"                    if @limit
            sql << " OFFSET #{@offset}"                  if @offset
            sql
          end

          # Test if a visitable object has been visited
          #
          # @example
          #   visitor.visited?  # true or false
          #
          # @return [Boolean]
          #
          # @api public
          def visited?
            !@from.nil?
          end

        private

          # Return a list of columns in a header
          #
          # @param [Header] header
          #
          # @param [#[]] aliases
          #   optional aliases for the columns
          #
          # @return [Array<#to_s>]
          #
          # @api private
          def columns_for(header, aliases = {})
            header.map do |attribute|
              if aliases.key?(attribute)
                alias_for(attribute, aliases[attribute])
              else
                column_for(attribute)
              end
            end
          end

          # Return the column alias for an attribute
          #
          # @param [Attribute] attribute
          #
          # @param [Attribute, nil] alias_attribute
          #   attribute to use for the alias
          #
          # @return [#to_s]
          #
          # @api private
          def alias_for(attribute, alias_attribute)
            "#{column_for(attribute)} AS #{visit_identifier alias_attribute.name}"
          end

          # Return the column for an attribute
          #
          # @param [Attribute] attribute
          #
          # @return [#to_s]
          #
          # @api private
          def column_for(attribute)
            dispatch attribute
          end

        end # class UnaryRelation
      end # class Generator
    end # module Compiler
  end # module SQL
end # module Veritas
