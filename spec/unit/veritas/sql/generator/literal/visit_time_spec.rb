# encoding: utf-8

require 'spec_helper'

describe SQL::Generator::Literal, '#visit_time' do
  subject { object.visit_time(time) }

  # Time#iso8601 is currently broken in JRuby 1.6.1 when fractional seconds are not 0
  def self.time_iso8601_broken?
    RUBY_PLATFORM =~ /java/ && JRUBY_VERSION <= '1.6.1' && RUBY_VERSION >= '1.9.2'
  end

  let(:described_class) { Class.new(SQL::Generator::Visitor) { include SQL::Generator::Literal } }
  let(:object)          { described_class.new                                                    }

  before :all do
    @original_tz = ENV['TZ']
  end

  after :all do
    ENV['TZ'] = @original_tz
  end

  context 'when the Time is UTC' do
    context 'and the microseconds are equal to 0' do
      let(:usec) { 0                                               }
      let(:time) { Time.utc(2010, 12, 31, 23, 59, 59, usec).freeze }

      it_should_behave_like 'a generated SQL expression'

      its(:to_s) { should eql("'2010-12-31T23:59:59.000000000Z'") }
    end

    context 'and the microseconds are greater than 0' do
      let(:usec) { 1                                               }
      let(:time) { Time.utc(2010, 12, 31, 23, 59, 59, usec).freeze }

      it_should_behave_like 'a generated SQL expression'

      unless time_iso8601_broken?
        its(:to_s) { should eql("'2010-12-31T23:59:59.000001000Z'") }
      end
    end
  end

  context 'when the Time is local, and the local time zone is UTC' do
    before :all do
      ENV['TZ'] = 'UTC'
    end

    context 'and the microseconds are equal to 0' do
      let(:usec) { 0                                                 }
      let(:time) { Time.local(2010, 12, 31, 23, 59, 59, usec).freeze }

      it_should_behave_like 'a generated SQL expression'

      its(:to_s) { should eql("'2010-12-31T23:59:59.000000000Z'") }
    end

    context 'and the microseconds are greater than 0' do
      let(:usec) { 1                                                 }
      let(:time) { Time.local(2010, 12, 31, 23, 59, 59, usec).freeze }

      it_should_behave_like 'a generated SQL expression'

      unless time_iso8601_broken?
        its(:to_s) { should eql("'2010-12-31T23:59:59.000001000Z'") }
      end
    end
  end

  context 'when the Time is local, and the local time zone is not UTC' do
    before :all do
      ENV['TZ'] = 'America/Vancouver'
    end

    context 'and the microseconds are equal to 0' do
      let(:usec) { 0                                                 }
      let(:time) { Time.local(2010, 12, 31, 15, 59, 59, usec).freeze }

      it_should_behave_like 'a generated SQL expression'

      its(:to_s) { should eql("'2010-12-31T23:59:59.000000000Z'") }
    end

    context 'and the microseconds are greater than 0' do
      let(:usec) { 1                                                 }
      let(:time) { Time.local(2010, 12, 31, 15, 59, 59, usec).freeze }

      it_should_behave_like 'a generated SQL expression'

      unless time_iso8601_broken?
        its(:to_s) { should eql("'2010-12-31T23:59:59.000001000Z'") }
      end
    end
  end
end
