require 'spec_helper'

describe Generator::Literal, '#visit_date' do
  subject { object.visit_date(date) }

  let(:klass)  { Class.new(Visitor) { include Generator::Literal } }
  let(:date)   { Date.new(2010, 12, 31).freeze                     }
  let(:object) { klass.new                                         }

  it_should_behave_like 'a generated SQL expression'

  its(:to_s) { should eql("'2010-12-31'") }
end
