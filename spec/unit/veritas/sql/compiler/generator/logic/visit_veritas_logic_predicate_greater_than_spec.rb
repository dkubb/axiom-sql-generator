require 'spec_helper'

describe SQL::Compiler::Generator::Logic, '#visit_veritas_logic_predicate_greater_than' do
  subject { object.visit_veritas_logic_predicate_greater_than(greater_than) }

  let(:described_class) { Class.new(SQL::Compiler::Visitor) { include SQL::Compiler::Generator::Logic } }
  let(:greater_than)    { Attribute::Integer.new(:id).gt(1)                                             }
  let(:object)          { described_class.new                                                           }

  it_should_behave_like 'a generated SQL expression'

  its(:to_s) { should eql('"id" > 1') }
end
