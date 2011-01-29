require 'spec_helper'

describe Generator::Direction, '#visit_veritas_relation_operation_order_descending' do
  subject { object.visit_veritas_relation_operation_order_descending(direction) }

  let(:klass)     { Class.new(Visitor) { include Generator::Direction } }
  let(:direction) { Attribute::Integer.new(:id).asc                     }
  let(:object)    { klass.new                                           }

  it_should_behave_like 'a generated SQL expression'

  its(:to_s) { should eql('"id" DESC') }
end
