require 'spec_helper'

describe Generator::Literal, '#visit_date' do
  subject { object.visit_date(date) }

  let(:klass)  { Class.new(Visitor) { include Generator::Literal } }
  let(:date)   { Date.new(2010, 12, 31)                            }
  let(:object) { klass.new                                         }

  it_should_behave_like 'a generated SQL expression'

  it { should == "'2010-12-31'" }
end
