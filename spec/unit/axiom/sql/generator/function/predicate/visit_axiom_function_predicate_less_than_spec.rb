# encoding: utf-8

require 'spec_helper'

describe SQL::Generator::Function::Predicate, '#visit_axiom_function_predicate_less_than' do
  subject { object.visit_axiom_function_predicate_less_than(less_than) }

  let(:described_class) { Class.new(SQL::Generator::Visitor) { include SQL::Generator::Function::Predicate } }
  let(:less_than)       { Attribute::Integer.new(:id).lt(1)                                                  }
  let(:object)          { described_class.new                                                                }

  it_should_behave_like 'a generated SQL expression'

  its(:to_s) { should eql('"id" < 1') }
end
