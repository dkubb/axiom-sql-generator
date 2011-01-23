module Veritas
  module SQL
    module Compiler
      class Generator < Visitor

        # Generates an SQL statement for a literal
        module Literal

          TRUE          = 'TRUE'.freeze
          FALSE         = 'FALSE'.freeze
          NULL          = 'NULL'.freeze
          QUOTE         = "'".freeze
          ESCAPED_QUOTE = "''".freeze
          SEPARATOR     = ', '.freeze

          # Visit an Enumerable
          #
          # @param [Enumerable] enumerable
          #
          # @return [#to_s]
          #
          # @api private
          def visit_enumerable(enumerable)
            "(#{enumerable.map { |entry| dispatch entry }.join(SEPARATOR)})"
          end

          # Visit a String
          #
          # @param [String] string
          #
          # @return [#to_s]
          #
          # @api private
          def visit_string(string)
            "#{QUOTE}#{string.gsub(QUOTE, ESCAPED_QUOTE)}#{QUOTE}"
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

          # Visit a Class
          #
          # @param [Class] klass
          #
          # @return [#to_s]
          #
          # @api private
          def visit_class(klass)
            name = klass.name.to_s
            name.empty? ? NULL : visit_string(name)
          end

          # Visit a Date
          #
          # @param [Date] date
          #
          # @return [#to_s]
          #
          # @api private
          def visit_date(date)
            dispatch date.strftime('%Y-%m-%d')
          end

          # Visit a true value
          #
          # @param [true]
          #
          # @return [#to_s]
          #
          # @api private
          def visit_true_class(_true)
            TRUE
          end

          # Visit a false value
          #
          # @param [false]
          #
          # @return [#to_s]
          #
          # @api private
          def visit_false_class(_false)
            FALSE
          end

          # Visit a nil value
          #
          # @param [nil]
          #
          # @return [#to_s]
          #
          # @api private
          def visit_nil_class(_nil)
            NULL
          end

        end # module Literal
      end # class Generator
    end # module Compiler
  end # module SQL
end # module Veritas
