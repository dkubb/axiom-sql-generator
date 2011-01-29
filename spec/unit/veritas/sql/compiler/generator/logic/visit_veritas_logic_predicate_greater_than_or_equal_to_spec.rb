require 'spec_helper'

describe Generator::Logic, '#visit_veritas_logic_predicate_greater_than_or_equal_to' do
  subject { object.visit_veritas_logic_predicate_greater_than_or_equal_to(greater_than_or_equal_to) }

  let(:klass)                    { Class.new(Visitor) { include Generator::Logic } }
  let(:greater_than_or_equal_to) { Attribute::Integer.new(:id).gte(1)              }
  let(:object)                   { klass.new                                       }

  it_should_behave_like 'a generated SQL expression'

  its(:to_s) { should eql('"id" >= 1') }
end
