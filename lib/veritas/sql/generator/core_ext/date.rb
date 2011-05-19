# encoding: utf-8

# Extend Date with methods available in ruby 1.9
class Date

  ISO_8601_FORMAT = '%F'.freeze

  # Return the Date in ISO8601 date format
  #
  # @return [#to_s]
  #
  # @todo Remove once backports adds this method
  #
  # @api private
  def iso8601
    date = frozen? ? dup : self
    date.strftime(ISO_8601_FORMAT)
  end unless method_defined? :iso8601

end # class Date
