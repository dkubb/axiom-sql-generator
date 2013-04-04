# encoding: utf-8

require 'spec_helper'

describe SQL::Generator::Function::Numeric, '#visit_axiom_function_numeric_multiplication' do
  subject { object.visit_axiom_function_numeric_multiplication(multiplication) }

  let(:described_class) { Class.new(SQL::Generator::Visitor) { include SQL::Generator::Function::Numeric } }
  let(:multiplication)  { Attribute::Integer.new(:number).multiply(1)                                      }
  let(:object)          { described_class.new                                                              }

  it_should_behave_like 'a generated SQL expression'

  its(:to_s) { should eql('("number" * 1)') }
end
