# encoding: utf-8

require 'spec_helper'

describe SQL::Generator::Function::Numeric, '#visit_axiom_function_numeric_absolute' do
  subject { object.visit_axiom_function_numeric_absolute(absolute) }

  let(:described_class) { Class.new(SQL::Generator::Visitor) { include SQL::Generator::Function::Numeric } }
  let(:absolute)        { Attribute::Integer.new(:number).abs                                              }
  let(:object)          { described_class.new                                                              }

  it_should_behave_like 'a generated SQL expression'

  its(:to_s) { should eql('ABS ("number")') }
end
