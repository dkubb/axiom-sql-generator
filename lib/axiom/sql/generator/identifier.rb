# encoding: utf-8

module Axiom
  module SQL
    module Generator

      # Generates an SQL statement for an identifier
      module Identifier

        QUOTE         = '"'.freeze
        ESCAPED_QUOTE = '""'.freeze

        # Quote the identifier
        #
        # @param [#to_s] identifier
        #
        # @return [#to_s]
        #
        # @api private
        def visit_identifier(identifier)
          escaped = identifier.to_s.gsub(QUOTE, ESCAPED_QUOTE)
          escaped.insert(0, QUOTE) << QUOTE
        end

      end # module Identifier
    end # module Generator
  end # module SQL
end # module Axiom
