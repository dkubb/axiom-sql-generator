require 'spec_helper'

describe Generator::Direction, '#visit_veritas_relation_operation_order_descending' do
  subject { object.visit_veritas_relation_operation_order_descending(direction) }

  let(:klass)     { Class.new(Visitor) { include Generator::Direction } }
  let(:direction) { Attribute::Integer.new(:id).asc                     }
  let(:object)    { klass.new                                           }

  before do
    object.instance_variable_set(:@name, 'users')
  end

  it_should_behave_like 'a generated SQL expression'

  it { should == '"users"."id" DESC' }
end
