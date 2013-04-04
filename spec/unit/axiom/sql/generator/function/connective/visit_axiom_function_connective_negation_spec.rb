# encoding: utf-8

require 'spec_helper'

describe SQL::Generator::Function::Connective, '#visit_axiom_function_connective_negation' do
  subject { object.visit_axiom_function_connective_negation(negation) }

  let(:described_class) { Class.new(SQL::Generator::Visitor) { include SQL::Generator::Function::Connective } }
  let(:attribute)       { Attribute::Integer.new(:id)                                                         }
  let(:negation)        { Function::Connective::Negation.new(attribute.eq(1))                                 }
  let(:object)          { described_class.new                                                                 }

  before do
    described_class.class_eval { include SQL::Generator::Function::Predicate }
  end

  it_should_behave_like 'a generated SQL expression'

  its(:to_s) { should eql('NOT ("id" = 1)') }
end
