# encoding: utf-8

require 'spec_helper'

describe SQL::Generator::Function::Numeric, '#visit_veritas_function_numeric_unary_plus' do
  subject { object.visit_veritas_function_numeric_unary_plus(unary_plus) }

  let(:described_class) { Class.new(SQL::Generator::Visitor) { include SQL::Generator::Function::Numeric } }
  let(:unary_plus)      { Attribute::Integer.new(:number).unary_plus                                       }
  let(:object)          { described_class.new                                                              }

  it_should_behave_like 'a generated SQL expression'

  its(:to_s) { should eql('+ ("number")') }
end
