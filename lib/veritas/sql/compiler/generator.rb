module Veritas
  module SQL
    module Compiler

      # Generates an SQL statement for a relation
      class Generator

        # Raised when the object is not handled by the generator
        class UnknownObject < StandardError; end

        # Lookup the handler method for a visitable object
        #
        # @param [Visitable] visitable
        #
        # @return [#to_sym]
        #
        # @raise [UnknownObject]
        #   raised when the visitable object has no handler
        #
        # @api private
        def self.handler_for(visitable)
          klass = visitable.class
          handlers[klass] or raise UnknownObject, "No handler for #{klass}"
        end

        # Return the handler method for a given module
        #
        # @param [Module] mod
        #
        # @return [Symbol]
        #
        # @api private
        def self.method_for(mod)
          "visit_#{mod.name.gsub(/([a-z])([A-Z])/, '\1_\2').gsub('::', '_').downcase}".to_sym
        end

        # Return handler methods for a module's ancestors
        #
        # @param [Module] mod
        #
        # @return [Array<Symbol>]
        #
        # @api private
        def self.ancestor_methods_for(mod)
          mod.ancestors.map { |ancestor| method_for(ancestor) }
        end

        # Return the handler cache that maps modules to method names
        #
        # @return [Hash]
        #
        # @api private
        def self.handlers
          @handlers ||= Hash.new do |hash, key|
            hash[key] = ancestor_methods_for(key).detect do |method|
              private_method_defined?(method)
            end
          end
        end

        private_class_method :method_for, :ancestor_methods_for, :handlers

        # Initialize a Generator
        #
        # @return [undefined]
        #
        # @api private
        def initialize
          @sql = ''
        end

        # Visit an object and generate SQL from each node
        #
        # @example
        #   generator.visit(visitable)
        #
        # @param [Visitable] visitable
        #   A visitable object
        #
        # @return [self]
        #
        # @raise [UnknownObject]
        #   raised when the visitable object has no handler
        #
        # @api public
        def visit(visitable)
          dispatch(visitable)
          generate_sql
          freeze
        end

        # Returns the current SQL string
        #
        # @example
        #   sql = generator.to_sql
        #
        # @return [String]
        #
        # @api public
        def to_sql
          @sql
        end

      private

        # Dispatch the visitable object to a handler method
        #
        # @param [Visitable] visitable
        #
        # @return [#to_s]
        #
        # @raise [UnknownObject]
        #   raised when the visitable object has no handler
        #
        # @api private
        def dispatch(visitable)
          send(self.class.handler_for(visitable), visitable)
        end

        # Quote the identifier
        #
        # @param [#to_s] identifier
        #
        # @return [String]
        #
        # @api private
        def quote_identifier(identifier)
          %'"#{identifier.to_s.gsub('"', '""')}"'
        end

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
          "#{column_for(attribute)} AS #{quote_identifier alias_attribute.name}"
        end

        # Return the SQL for the visitable object
        #
        # @return [#to_s]
        #
        # @api private
        def generate_sql
          @sql = "SELECT DISTINCT #{@columns.join(', ')} FROM #{quote_identifier @name}"
          @sql << " WHERE #{@where}"               if @where
          @sql << " ORDER BY #{@order.join(', ')}" if @order
          @sql << " LIMIT #{@limit}"               if @limit
          @sql << " OFFSET #{@offset}"             if @offset
          @sql.freeze
        end

        # Visit a Base Relation
        #
        # @param [BaseRelation] base_relation
        #
        # @return [undefined]
        #
        # @api private
        def visit_veritas_base_relation(base_relation)
          @name    = base_relation.name
          @columns = columns_for(base_relation.header)
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
        end

        # Visit an Attribute
        #
        # @param [Attribute] attribute
        #
        # @return [#to_s]
        #
        # @api private
        def visit_veritas_attribute(attribute)
          "#{quote_identifier @name}.#{quote_identifier attribute.name}"
        end

        # Visit an Equality predicate
        #
        # @param [Logic::Predicate::Equality] equality
        #
        # @return [#to_s]
        #
        # @api private
        def visit_veritas_logic_predicate_equality(equality)
          "#{dispatch equality.left} = #{dispatch equality.right}"
        end

        # Visit an Ascending Direction
        #
        # @param [Relation::Operation::Order::Ascending] direction
        #
        # @return [#to_s]
        #
        # @api private
        def visit_veritas_relation_operation_order_ascending(direction)
          dispatch direction.attribute
        end

        # Visit an Descending Direction
        #
        # @param [Relation::Operation::Order::Descending] direction
        #
        # @return [#to_s]
        #
        # @api private
        def visit_veritas_relation_operation_order_descending(direction)
          "#{dispatch direction.attribute} DESC"
        end

        # Visit a Numeric
        #
        # @param [Numeric] numeric
        #
        # @return [#to_s]
        #
        # @api private
        def visit_numeric(numeric)
          numeric.to_s
        end

      end # class Generator
    end # module Compiler
  end # module SQL
end # module Veritas
