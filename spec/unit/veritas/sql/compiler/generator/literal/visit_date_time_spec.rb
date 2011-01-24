require 'spec_helper'

describe Generator::Literal, '#visit_date_time' do
  subject { object.visit_date_time(date_time) }

  let(:klass)  { Class.new(Visitor) { include Generator::Literal } }
  let(:object) { klass.new                                         }

  context 'when the DateTime is UTC' do
    context 'and the microseconds are equal to 0' do
      let(:date_time) { DateTime.new(2010, 12, 31, 23, 59, 59) }

      it_should_behave_like 'a generated SQL expression'

      it { should == "'2010-12-31T23:59:59+00:00'" }
    end

    context 'and the microseconds are greater than 0' do
      let(:date_time) { DateTime.new(2010, 12, 31, 23, 59, 59 + Rational(1, 10**6)) }

      it_should_behave_like 'a generated SQL expression'

      it { should == "'2010-12-31T23:59:59.000001+00:00'" }
    end
  end

  context 'when the DateTime is not UTC' do
    let(:offset) { Rational(-28800, 60 * 60 * 24) }

    context 'and the microseconds are equal to 0' do
      let(:date_time) { DateTime.new(2010, 12, 31, 15, 59, 59, offset) }

      it_should_behave_like 'a generated SQL expression'

      it { should == "'2010-12-31T23:59:59+00:00'" }
    end

    context 'and the microseconds are greater than 0' do
      let(:date_time) { DateTime.new(2010, 12, 31, 15, 59, 59 + Rational(1, 10**6), offset) }

      it_should_behave_like 'a generated SQL expression'

      it { should == "'2010-12-31T23:59:59.000001+00:00'" }
    end
  end
end
