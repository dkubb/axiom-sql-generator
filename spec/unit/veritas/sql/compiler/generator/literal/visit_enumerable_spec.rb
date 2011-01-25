require 'spec_helper'

describe Generator::Literal, '#visit_enumerable' do
  subject { object.visit_enumerable(enumerable) }

  let(:klass)      { Class.new(Visitor) { include Generator::Literal } }
  let(:enumerable) { [ 1, 2 ].freeze                                   }
  let(:object)     { klass.new                                         }

  it_should_behave_like 'a generated SQL expression'

  it { should == '(1, 2)' }
end
