module Veritas
  module SQL
    module Compiler
      class Generator < Visitor

        # Generates an SQL statement for an identifer
        module Identifier

          QUOTE         = '"'.freeze
          ESCAPED_QUOTE = '""'.freeze

          # Quote the identifier
          #
          # @param [#to_s] identifier
          #
          # @return [String]
          #
          # @api private
          def visit_identifier(identifier)
            "#{QUOTE}#{identifier.to_s.gsub(QUOTE, ESCAPED_QUOTE)}#{QUOTE}"
          end

        end # module Identifier
      end # class Generator
    end # module Compiler
  end # module SQL
end # module Veritas
