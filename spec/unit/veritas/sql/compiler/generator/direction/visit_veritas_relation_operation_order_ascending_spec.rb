require 'spec_helper'

describe Generator::Direction, '#visit_veritas_relation_operation_order_ascending' do
  subject { object.visit_veritas_relation_operation_order_ascending(direction) }

  let(:klass)     { Class.new(Visitor) { include Generator::Direction } }
  let(:direction) { Attribute::Integer.new(:id).asc                     }
  let(:object)    { klass.new                                           }

  before do
    object.instance_variable_set(:@base_relation, 'users')
  end

  it_should_behave_like 'a generated SQL expression'

  it { should == '"users"."id"' }
end
