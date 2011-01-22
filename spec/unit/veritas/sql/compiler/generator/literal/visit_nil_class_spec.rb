require 'spec_helper'

describe Generator::Literal, '#visit_nil_class' do
  subject { object.visit_nil_class(nil) }

  let(:klass)  { Class.new(Visitor) { include Generator::Literal } }
  let(:object) { klass.new                                         }

  it_should_behave_like 'a generated SQL expression'

  it { should == 'NULL' }
end
