# encoding: utf-8

require 'spec_helper'

describe SQL::Generator::Function::Numeric, '#visit_axiom_function_numeric_square_root' do
  subject { object.visit_axiom_function_numeric_square_root(square_root) }

  let(:described_class) { Class.new(SQL::Generator::Visitor) { include SQL::Generator::Function::Numeric } }
  let(:square_root)     { Attribute::Integer.new(:number).square_root                                      }
  let(:object)          { described_class.new                                                              }

  it_should_behave_like 'a generated SQL expression'

  its(:to_s) { should eql('SQRT ("number")') }
end
