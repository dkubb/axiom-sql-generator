# encoding: utf-8

require 'spec_helper'

describe SQL::Generator::Function::Predicate, '#visit_axiom_function_predicate_greater_than_or_equal_to' do
  subject { object.visit_axiom_function_predicate_greater_than_or_equal_to(greater_than_or_equal_to) }

  let(:described_class)          { Class.new(SQL::Generator::Visitor) { include SQL::Generator::Function::Predicate } }
  let(:greater_than_or_equal_to) { Attribute::Integer.new(:id).gte(1)                                                 }
  let(:object)                   { described_class.new                                                                }

  it_should_behave_like 'a generated SQL expression'

  its(:to_s) { should eql('"id" >= 1') }
end
