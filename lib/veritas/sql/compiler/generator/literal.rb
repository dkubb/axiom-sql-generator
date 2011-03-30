# encoding: utf-8

module Veritas
  module SQL
    module Compiler
      module Generator

        # Generates an SQL statement for a literal
        module Literal

          TRUE            = 'TRUE'.freeze
          FALSE           = 'FALSE'.freeze
          NULL            = 'NULL'.freeze
          QUOTE           = "'".freeze
          ESCAPED_QUOTE   = "''".freeze
          SEPARATOR       = ', '.freeze
          DATE_FORMAT     = '%F'.freeze
          DATETIME_FORMAT = "#{DATE_FORMAT}T%T.%N%Z".freeze
          TIME_SCALE      = 9

          # Returns an unfrozen object
          #
          # Some objects, like Date, DateTime and Time memoize values
          # when serialized to a String, so when they are frozen this will
          # dup them and then return the unfrozen copy.
          #
          # @param [Object] object
          #
          # @return [Object]
          #   non-frozen object
          #
          # @api private
          def self.dup_frozen(object)
            object.frozen? ? object.dup : object
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
          # @note The string must be utf-8 encoded
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

          # Visit a Date and return in ISO 8601 date format
          #
          # @param [Date] date
          #
          # @return [#to_s]
          #
          # @todo use Date#iso8601 when added to 1.8.7 by backports
          #
          # @api private
          def visit_date(date)
            dispatch Literal.dup_frozen(date).strftime(DATE_FORMAT)
          end

          # Visit a DateTime and return in ISO 8601 date-time format
          #
          # Converts the DateTime to UTC format.
          #
          # @param [DateTime] date_time
          #
          # @return [#to_s]
          #
          # @todo use DateTime#iso8601(TIME_SCALE) when added to 1.8.7 by backports
          #
          # @api private
          def visit_date_time(date_time)
            dispatch date_time.new_offset.strftime(DATETIME_FORMAT)
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
            dispatch Literal.dup_frozen(time).utc.iso8601(TIME_SCALE)
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
      end # module Generator
    end # module Compiler
  end # module SQL
end # module Veritas
