require 'spec_helper'

describe Generator::Literal, '.format_time' do
  subject { object.format_time(time, usec) }

  let(:object) { Generator::Literal }

  context 'when time is a DateTime object' do
    let(:usec_in_seconds) { Rational(usec, 10**6) }

    context 'and the microseconds are equal to 0' do
      let(:usec) { 0                                                        }
      let(:time) { DateTime.new(2010, 12, 31, 23, 59, 59 + usec_in_seconds) }

      it { should respond_to(:to_s) }

      it { should == '2010-12-31T23:59:59+00:00' }
    end

    context 'and the microseconds are greater than 0' do
      let(:usec) { 1                                                        }
      let(:time) { DateTime.new(2010, 12, 31, 23, 59, 59 + usec_in_seconds) }

      it { should respond_to(:to_s) }

      it { should == '2010-12-31T23:59:59.000001+00:00' }
    end
  end

  context 'when time is a Time object' do
    context 'and the microseconds are equal to 0' do
      let(:usec) { 0                                        }
      let(:time) { Time.utc(2010, 12, 31, 23, 59, 59, usec) }

      it { should respond_to(:to_s) }

      it { should == '2010-12-31T23:59:59+00:00' }
    end

    context 'and the microseconds are greater than 0' do
      let(:usec) { 1                                        }
      let(:time) { Time.utc(2010, 12, 31, 23, 59, 59, usec) }

      it { should respond_to(:to_s) }

      it { should == '2010-12-31T23:59:59.000001+00:00' }
    end
  end
end
