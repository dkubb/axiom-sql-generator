# encoding: utf-8

# Extend DateTime with methods available in ruby 1.9
class DateTime

  SEC_FRACTION_MULTIPLIER = RUBY_VERSION < '1.9' ? 60 * 60 * 24 : 1

  # Return the DateTime in ISO8601 date-time format
  #
  # @param [Integer] time_scale
  #   the number of significant digits to use for fractional seconds
  #
  # @return [#to_s]
  #
  # @todo Remove once backports adds this method
  #
  # @api private
  def iso8601(time_scale = 0)
    super() + iso8601_timediv(time_scale)
  end unless method_defined?(:iso8601) && instance_method(:iso8601).arity == 1

private

  # Return the time with fraction seconds
  #
  # @param [Integer] time_scale
  #   the number of significant digits to use for fractional seconds
  #
  # @return [#to_s]
  #
  # @api private
  def iso8601_timediv(time_scale)
    date_time = frozen? ? dup : self

    fractional_seconds = unless time_scale.zero?
      '.%0*d' % [
        time_scale,
        date_time.sec_fraction * SEC_FRACTION_MULTIPLIER * 10**time_scale
      ]
    end

    date_time.strftime("T%T#{fractional_seconds}%Z")
  end unless method_defined? :iso8601_timediv

end # class Date
