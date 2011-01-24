module Veritas
  module SQL
    module Compiler
      class Generator < Visitor

        # Generates an SQL statement for a literal
        module Literal

          TRUE                 = 'TRUE'.freeze
          FALSE                = 'FALSE'.freeze
          NULL                 = 'NULL'.freeze
          QUOTE                = "'".freeze
          ESCAPED_QUOTE        = "''".freeze
          SEPARATOR            = ', '.freeze
          MICROSECONDS_PER_DAY = 60 * 60 * 24 * 10**6;
          TIME_FORMAT          = '%Y-%m-%dT%H:%M:%S'.freeze
          USEC_FORMAT          = '.%06d'.freeze
          UTC_OFFSET           = '+00:00'.freeze

          # Format the time, appending microseconds and the UTC offset
          #
          # @param [#strftime] time
          #   the DateTime or Time object to format
          # @param [Integer] usec
          #   the number of microseconds in the time
          #
          # @return [#to_s]
          #
          # @api private
          def self.format_time(time, usec)
            formatted = time.strftime(TIME_FORMAT)
            formatted << USEC_FORMAT % usec unless usec.zero?
            formatted << UTC_OFFSET
          end

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
            dispatch date.to_s
          end

          # Visit a DateTime
          #
          # Converts the DateTime to UTC format.
          #
          # @param [DateTime] date_time
          #
          # @return [#to_s]
          #
          # @api private
          def visit_date_time(date_time)
            usec = date_time.sec_fraction * MICROSECONDS_PER_DAY
            dispatch Literal.format_time(date_time.new_offset(0), usec.to_i)
          end

          # Visit a Time
          #
          # Converts the Time to UTC format.
          #
          # @param [Time] time
          #
          # @return [#to_s]
          #
          # @api private
          def visit_time(time)
            dispatch Literal.format_time(time.utc, time.usec)
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
