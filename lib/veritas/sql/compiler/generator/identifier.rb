module Veritas
  module SQL
    module Compiler
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
            "#{QUOTE}#{identifier.to_s.gsub(QUOTE, ESCAPED_QUOTE)}#{QUOTE}"
          end

        end # module Identifier
      end # module Generator
    end # module Compiler
  end # module SQL
end # module Veritas
