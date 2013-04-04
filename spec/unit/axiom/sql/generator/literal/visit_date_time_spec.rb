# encoding: utf-8

require 'spec_helper'

describe SQL::Generator::Literal, '#visit_date_time' do
  subject { object.visit_date_time(date_time) }

  let(:described_class) { Class.new(SQL::Generator::Visitor) { include SQL::Generator::Literal } }
  let(:nsec_in_seconds) { Rational(nsec, 10**9)                                                  }
  let(:object)          { described_class.new                                                    }

  context 'when the DateTime is UTC' do
    let(:offset) { 0 }

    context 'and the nanoseconds are equal to 0' do
      let(:nsec)      { 0                                                                       }
      let(:date_time) { DateTime.new(2010, 12, 31, 23, 59, 59 + nsec_in_seconds, offset).freeze }

      it_should_behave_like 'a generated SQL expression'

      its(:to_s) { should eql("'2010-12-31T23:59:59.000000000+00:00'") }
    end

    context 'and the nanoseconds are greater than 0' do
      let(:nsec)      { 1                                                                       }
      let(:date_time) { DateTime.new(2010, 12, 31, 23, 59, 59 + nsec_in_seconds, offset).freeze }

      it_should_behave_like 'a generated SQL expression'

      its(:to_s) { should eql("'2010-12-31T23:59:59.000000001+00:00'") }
    end
  end

  context 'when the DateTime is not UTC' do
    let(:offset) { Rational(-8, 24) }

    context 'and the nanoseconds are equal to 0' do
      let(:nsec)      { 0                                                                       }
      let(:date_time) { DateTime.new(2010, 12, 31, 15, 59, 59 + nsec_in_seconds, offset).freeze }

      it_should_behave_like 'a generated SQL expression'

      its(:to_s) { should eql("'2010-12-31T23:59:59.000000000+00:00'") }
    end

    context 'and the nanoseconds are greater than 0' do
      let(:nsec)      { 1                                                                       }
      let(:date_time) { DateTime.new(2010, 12, 31, 15, 59, 59 + nsec_in_seconds, offset).freeze }

      it_should_behave_like 'a generated SQL expression'

      its(:to_s) { should eql("'2010-12-31T23:59:59.000000001+00:00'") }
    end
  end
end
