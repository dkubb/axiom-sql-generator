# encoding: utf-8

require 'spec_helper'

describe SQL::Generator::Logic, '#visit_veritas_logic_predicate_equality' do
  subject { object.visit_veritas_logic_predicate_equality(equality) }

  let(:described_class) { Class.new(SQL::Generator::Visitor) { include SQL::Generator::Logic } }
  let(:attribute)       { Attribute::Integer.new(:id)                                          }
  let(:object)          { described_class.new                                                  }

  context 'when the right operand is not nil' do
    let(:equality) { attribute.eq(1) }

    it_should_behave_like 'a generated SQL expression'

    its(:to_s) { should eql('"id" = 1') }
  end

  context 'when the right operand is nil' do
    let(:equality) { attribute.eq(nil) }

    it_should_behave_like 'a generated SQL expression'

    its(:to_s) { should eql('"id" IS NULL') }
  end
end
