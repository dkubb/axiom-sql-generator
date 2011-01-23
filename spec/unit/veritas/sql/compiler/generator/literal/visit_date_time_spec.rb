require 'spec_helper'

describe Generator::Literal, '#visit_date_time' do
  subject { object.visit_date_time(date_time) }

  let(:klass)     { Class.new(Visitor) { include Generator::Literal } }
  let(:date_time) { DateTime.new(2010, 12, 31, 23, 59, 59)            }
  let(:object)    { klass.new                                         }

  it_should_behave_like 'a generated SQL expression'

  it { should == "'2010-12-31T23:59:59+00:00'" }
end
