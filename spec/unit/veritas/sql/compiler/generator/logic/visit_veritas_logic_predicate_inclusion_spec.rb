require 'spec_helper'

describe Generator::Logic, '#visit_veritas_logic_predicate_inclusion' do
  subject { object.visit_veritas_logic_predicate_inclusion(inclusion) }

  let(:described_class) { Class.new(Visitor) { include Generator::Logic } }
  let(:attribute)       { Attribute::Integer.new(:id)                     }
  let(:object)          { described_class.new                             }

  context 'when right operand is an inclusive Range' do
    let(:inclusion) { attribute.exclude(1..10) }

    it_should_behave_like 'a generated SQL expression'

    its(:to_s) { should eql('"id" BETWEEN 1 AND 10') }
  end

  context 'when right operand is an exclusive Range' do
    let(:inclusion) { attribute.exclude(1...10) }

    it_should_behave_like 'a generated SQL expression'

    its(:to_s) { should eql('("id" >= 1 AND "id" < 10)') }
  end

  context 'when right operand is an Array' do
    let(:inclusion) { attribute.exclude([ 1, 2 ]) }

    it_should_behave_like 'a generated SQL expression'

    its(:to_s) { should eql('"id" IN (1, 2)') }
  end

  context 'when right operand is an empty Array' do
    let(:inclusion) { attribute.exclude([]) }

    it_should_behave_like 'a generated SQL expression'

    its(:to_s) { should eql('1 = 0') }
  end
end
