require 'spec_helper'

describe Generator::Logic, '#visit_veritas_logic_predicate_less_than' do
  subject { object.visit_veritas_logic_predicate_less_than(less_than) }

  let(:klass)     { Class.new(Visitor) { include Generator::Logic } }
  let(:less_than) { Attribute::Integer.new(:id).gt(1)               }
  let(:object)    { klass.new                                       }

  before do
    object.instance_variable_set(:@name, 'users')
  end

  it_should_behave_like 'a generated SQL expression'

  it { should == '"users"."id" < 1' }
end
