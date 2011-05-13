# encoding: utf-8

require 'spec_helper'

describe SQL::Generator::Function::Numeric, '#visit_veritas_function_numeric_subtraction' do
  subject { object.visit_veritas_function_numeric_subtraction(subtraction) }

  let(:described_class) { Class.new(SQL::Generator::Visitor) { include SQL::Generator::Function::Numeric } }
  let(:subtraction)     { Attribute::Integer.new(:number).subtract(1)                                      }
  let(:object)          { described_class.new                                                              }

  it_should_behave_like 'a generated SQL expression'

  its(:to_s) { should eql('("number" - 1)') }
end
