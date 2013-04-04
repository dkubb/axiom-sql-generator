# encoding: utf-8

require 'spec_helper'

describe SQL::Generator::Function::Numeric, '#visit_axiom_function_numeric_exponentiation' do
  subject { object.visit_axiom_function_numeric_exponentiation(exponentiation) }

  let(:described_class) { Class.new(SQL::Generator::Visitor) { include SQL::Generator::Function::Numeric } }
  let(:exponentiation)  { Attribute::Integer.new(:number).exponent(1)                                      }
  let(:object)          { described_class.new                                                              }

  it_should_behave_like 'a generated SQL expression'

  its(:to_s) { should eql('POWER ("number", 1)') }
end
