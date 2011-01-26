require 'spec_helper'

describe Generator::Logic, '#visit_veritas_logic_predicate_exclusion' do
  subject { object.visit_veritas_logic_predicate_exclusion(exclusion) }

  let(:klass)     { Class.new(Visitor) { include Generator::Logic } }
  let(:attribute) { Attribute::Integer.new(:id)                     }
  let(:object)    { klass.new                                       }

  before do
    object.instance_variable_set(:@name, 'users')
  end

  context 'when right operand is an inclusive Range' do
    let(:exclusion) { attribute.exclude(1..10) }

    it_should_behave_like 'a generated SQL expression'

    it { should == '"users"."id" NOT BETWEEN 1 AND 10' }
  end

  context 'when right operand is an exclusive Range' do
    let(:exclusion) { attribute.exclude(1...10) }

    it_should_behave_like 'a generated SQL expression'

    it { should == '("users"."id" < 1 OR "users"."id" >= 10)' }
  end

  context 'when right operand is an Array' do
    let(:exclusion) { attribute.exclude([ 1, 2 ]) }

    it_should_behave_like 'a generated SQL expression'

    it { should == '"users"."id" NOT IN (1, 2)' }
  end

  context 'when right operand is an empty Array' do
    let(:exclusion) { attribute.exclude([]) }

    it_should_behave_like 'a generated SQL expression'

    it { should == '1 = 1' }
  end
end
