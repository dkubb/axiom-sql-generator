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
          predicate_sql(equality.right.nil? ? 'IS' : '=', equality)
        end

        # Visit an Inequality predicate
        #
        # @param [Logic::Predicate::Inequality] inequality
        #
        # @return [#to_s]
        #
        # @api private
        def visit_veritas_logic_predicate_inequality(inequality)
          predicate_sql(inequality.right.nil? ? 'IS NOT' : '<>', inequality)
        end

        # Visit an GreaterThan predicate
        #
        # @param [Logic::Predicate::GreaterThan] greater_than
        #
        # @return [#to_s]
        #
        # @api private
        def visit_veritas_logic_predicate_greater_than(greater_than)
          predicate_sql('>', greater_than)
        end

        # Visit an GreaterThanOrEqualTo predicate
        #
        # @param [Logic::Predicate::GreaterThanOrEqualTo] greater_than_or_equal_to
        #
        # @return [#to_s]
        #
        # @api private
        def visit_veritas_logic_predicate_greater_than_or_equal_to(greater_than_or_equal_to)
          predicate_sql('>=', greater_than_or_equal_to)
        end

        # Visit an LessThan predicate
        #
        # @param [Logic::Predicate::LessThan] less_than
        #
        # @return [#to_s]
        #
        # @api private
        def visit_veritas_logic_predicate_less_than(less_than)
          predicate_sql('<', less_than)
        end

        # Visit an LessThanOrEqualTo predicate
        #
        # @param [Logic::Predicate::LessThanOrEqualTo] less_than_or_equal_to
        #
        # @return [#to_s]
        #
        # @api private
        def visit_veritas_logic_predicate_less_than_or_equal_to(less_than_or_equal_to)
          predicate_sql('<=', less_than_or_equal_to)
        end

        # Visit an Inclusion predicate
        #
        # @param [Logic::Predicate::Inclusion] inclusion
        #
        # @return [#to_s]
        #
        # @api private
        def visit_veritas_logic_predicate_inclusion(inclusion)
          left, right = inclusion.left, inclusion.right
          if right.kind_of?(Range)
            range_inclusion_sql(left, right)
          else
            enumerable_sql('IN', left, right)
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
          left, right = exclusion.left, exclusion.right
          if right.kind_of?(Range)
            range_exclusion_sql(left, right)
          else
            enumerable_sql('NOT IN', left, right)
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
          "(#{dispatch conjunction.left} AND #{dispatch conjunction.right})"
        end

        # Visit an Disjunction connective
        #
        # @param [Logic::Connective::Disjunction] disjunction
        #
        # @return [#to_s]
        #
        # @api private
        def visit_veritas_logic_connective_disjunction(disjunction)
          "(#{dispatch disjunction.left} OR #{dispatch disjunction.right})"
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

        # Visit an Enumerable
        #
        # @param [Enumerable] enumerable
        #
        # @return [#to_s]
        #
        # @api private
        def visit_enumerable(enumerable)
          "#{enumerable.map { |entry| dispatch entry }.join(', ')}"
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

        # Visit a nil
        #
        # @return [#to_s]
        #
        # @api private
        def visit_nil_class(*)
          'NULL'
        end

        # Return the SQL for an Inclusion using a Range
        #
        # @param [Object] left
        #
        # @param [Range] right
        #
        # @return [#to_s]
        #
        # @api private
        def range_inclusion_sql(left, right)
          if right.exclude_end?
            exclusive_range_inclusion_sql(left, right)
          else
            inclusive_range_sql('BETWEEN', left, right)
          end
        end

        # Return the SQL for an Exclusion using a Range
        #
        # @param [Object] left
        #
        # @param [Range] right
        #
        # @return [#to_s]
        #
        # @api private
        def range_exclusion_sql(left, right)
          if right.exclude_end?
            exclusive_range_exclusion_sql(left, right)
          else
            inclusive_range_sql('NOT BETWEEN', left, right)
          end
        end

        # Return the SQL for an Inclusion using an exclusive Range
        #
        # @param [Object] left
        #
        # @param [Range] right
        #
        # @return [#to_s]
        #
        # @api private
        def exclusive_range_inclusion_sql(left, right)
          dispatch Logic::Predicate::GreaterThanOrEqualTo.new(left, right.first).and(
            Logic::Predicate::LessThan.new(left, right.last)
          )
        end

        # Return the SQL for an Exclusion using an exclusive Range
        #
        # @param [Object] left
        #
        # @param [Range] right
        #
        # @return [#to_s]
        #
        # @api private
        def exclusive_range_exclusion_sql(left, right)
          dispatch Logic::Predicate::LessThan.new(left, right.first).or(
            Logic::Predicate::GreaterThanOrEqualTo.new(left, right.last)
          )
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
        def predicate_sql(operator, predicate)
          "#{dispatch predicate.left} #{operator} #{dispatch predicate.right}"
        end

        # Return the SQL for an operation using an inclusive Range
        #
        # @param [#to_s] operator
        #
        # @param [Object] left
        #
        # @param [Range] right
        #
        # @return [#to_s]
        #
        # @api private
        def inclusive_range_sql(operator, left, right)
          "#{dispatch left} #{operator} #{dispatch right.first} AND #{dispatch right.last}"
        end

        # Return the SQL for an operation using an Enumerable
        #
        # @param [#to_s] operator
        #
        # @param [Object] left
        #
        # @param [Enumerable] right
        #
        # @return [#to_s]
        #
        # @api private
        def enumerable_sql(operator, left, right)
          "#{dispatch left} #{operator} (#{dispatch right})"
        end

      end # class Generator
    end # module Compiler
  end # module SQL
end # module Veritas
