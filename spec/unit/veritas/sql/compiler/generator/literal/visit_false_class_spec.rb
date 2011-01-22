require 'spec_helper'

describe Generator::Literal, '#visit_false_class' do
  subject { object.visit_false_class(false) }

  let(:klass)  { Class.new(Visitor) { include Generator::Literal } }
  let(:object) { klass.new                                         }

  it_should_behave_like 'a generated SQL expression'

  it { should == 'FALSE' }
end
