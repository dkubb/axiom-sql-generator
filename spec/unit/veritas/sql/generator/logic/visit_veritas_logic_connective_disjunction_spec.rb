# encoding: utf-8

require 'spec_helper'

describe SQL::Generator::Logic, '#visit_veritas_logic_connective_disjunction' do
  subject { object.visit_veritas_logic_connective_disjunction(disjunction) }

  let(:described_class) { Class.new(SQL::Generator::Visitor) { include SQL::Generator::Logic } }
  let(:attribute)       { Attribute::Integer.new(:id)                                          }
  let(:disjunction)     { attribute.eq(1).or(attribute.eq(2))                                  }
  let(:object)          { described_class.new                                                  }

  it_should_behave_like 'a generated SQL expression'

  its(:to_s) { should eql('("id" = 1 OR "id" = 2)') }
end
