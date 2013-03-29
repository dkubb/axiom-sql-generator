# encoding: utf-8

require 'spec_helper'

describe SQL::Generator::Function::Numeric, '#visit_axiom_function_numeric_division' do
  subject { object.visit_axiom_function_numeric_division(division) }

  let(:described_class) { Class.new(SQL::Generator::Visitor) { include SQL::Generator::Function::Numeric } }
  let(:division)        { Attribute::Integer.new(:number).divide(1)                                        }
  let(:object)          { described_class.new                                                              }

  it_should_behave_like 'a generated SQL expression'

  its(:to_s) { should eql('("number" / 1)') }
end
