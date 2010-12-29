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

        # Return a list of columns in a relation
        #
        # @param [#header] relation
        #
        # @return [Array<#to_s>]
        #
        # @api private
        def columns_for(relation)
          relation.header.map { |attribute| dispatch attribute }
        end

        # Return the SQL for the visitable object
        #
        # @return [#to_s]
        #
        # @api private
        def generate_sql
          @sql = "SELECT #{@columns.join(', ')} FROM #{@name}".freeze
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
          @columns = columns_for(base_relation)
        end

        # Visit a Projection
        #
        # @param [Projection] projection
        #
        # @return [undefined]
        #
        # @api private
        def visit_veritas_algebra_projection(projection)
          dispatch projection.operand
          @columns = columns_for(projection)
        end

        # Visit an Attribute
        #
        # @param [Attribute] attribute
        #
        # @return [#to_s]
        #
        # @api private
        def visit_veritas_attribute(attribute)
          attribute.name
        end

      end # class Generator
    end # module Compiler
  end # module SQL
end # module Veritas
