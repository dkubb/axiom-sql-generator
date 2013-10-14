# encoding: utf-8

module Axiom
  module SQL
    module Generator

      # Visit each node in a axiom AST and execute an associated method
      class Visitor

        # Raised when the object is not handled by the generator
        class UnknownObject < StandardError; end

        NAME_SEP_REGEXP = /([a-z])([A-Z])/.freeze
        NAME_REP        = '\1_\2'.freeze
        DOUBLE_COLON    = '::'.freeze
        UNDERSCORE      = '_'.freeze

        # Lookup the handler method for a visitable class
        #
        # @param [Class<Visitable>] visitable_class
        #
        # @return [#to_sym]
        #
        # @raise [UnknownObject]
        #   raised when the visitable object has no handler
        #
        # @api private
        def self.handler_for(visitable_class)
          handlers[visitable_class] or fail UnknownObject, "No handler for #{visitable_class} in #{self}"
        end

        # Return the handler cache that maps modules to method names
        #
        # @return [Hash]
        #
        # @api private
        def self.handlers
          @handlers ||= Hash.new do |hash, key|
            hash[key] = ancestor_methods_for(key).detect do |method|
              method_defined?(method) || private_method_defined?(method)
            end
          end
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

        # Return the handler method for a given module
        #
        # @param [Module] mod
        #
        # @return [Symbol]
        #
        # @api private
        def self.method_for(mod)
          name = "visit_#{mod.name}"
          name.gsub!(NAME_SEP_REGEXP, NAME_REP)
          name.gsub!(DOUBLE_COLON,    UNDERSCORE)
          name.downcase!
          name.to_sym
        end

        private_class_method :handlers, :ancestor_methods_for, :method_for

        # Visit an object and generate SQL from each node
        #
        # @example
        #   generator.visit(visitable)
        #
        # @param [Visitable] _visitable
        #
        # @return [self]
        #
        # @raise [UnknownObject]
        #   raised when the visitable object has no handler
        #
        # @api public
        def visit(_visitable)
          fail NotImplementedError, "#{self.class}#visit must be implemented"
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
          fail NotImplementedError, "#{self.class}#visited? must be implemented"
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
          send(self.class.handler_for(visitable.class), visitable)
        end

      end # class Visitor
    end # module Generator
  end # module SQL
end # module Axiom
