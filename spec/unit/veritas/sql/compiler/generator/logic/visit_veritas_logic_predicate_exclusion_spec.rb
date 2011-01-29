require 'spec_helper'

describe Generator::Logic, '#visit_veritas_logic_predicate_exclusion' do
  subject { object.visit_veritas_logic_predicate_exclusion(exclusion) }

  let(:klass)     { Class.new(Visitor) { include Generator::Logic } }
  let(:attribute) { Attribute::Integer.new(:id)                     }
  let(:object)    { klass.new                                       }

  context 'when right operand is an inclusive Range' do
    let(:exclusion) { attribute.exclude(1..10) }

    it_should_behave_like 'a generated SQL expression'

    its(:to_s) { should eql('"id" NOT BETWEEN 1 AND 10') }
  end

  context 'when right operand is an exclusive Range' do
    let(:exclusion) { attribute.exclude(1...10) }

    it_should_behave_like 'a generated SQL expression'

    its(:to_s) { should eql('("id" < 1 OR "id" >= 10)') }
  end

  context 'when right operand is an Array' do
    let(:exclusion) { attribute.exclude([ 1, 2 ]) }

    it_should_behave_like 'a generated SQL expression'

    its(:to_s) { should eql('"id" NOT IN (1, 2)') }
  end

  context 'when right operand is an empty Array' do
    let(:exclusion) { attribute.exclude([]) }

    it_should_behave_like 'a generated SQL expression'

    its(:to_s) { should eql('1 = 1') }
  end
end
