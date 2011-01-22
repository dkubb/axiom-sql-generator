require 'spec_helper'

describe Generator::Logic, '#visit_veritas_logic_predicate_equality' do
  subject { object.visit_veritas_logic_predicate_equality(equality) }

  let(:klass)     { Class.new(Visitor) { include Generator::Logic } }
  let(:attribute) { Attribute::Integer.new(:id)                     }
  let(:object)    { klass.new                                       }

  before do
    object.instance_variable_set(:@base_relation, 'users')
  end

  context 'when the right operand is not nil' do
    let(:equality) { attribute.eq(1) }

    it_should_behave_like 'a generated SQL expression'

    it { should == '"users"."id" = 1' }
  end

  context 'when the right operand is nil' do
    let(:equality) { attribute.eq(nil) }

    it_should_behave_like 'a generated SQL expression'

    it { should == '"users"."id" IS NULL' }
  end
end
