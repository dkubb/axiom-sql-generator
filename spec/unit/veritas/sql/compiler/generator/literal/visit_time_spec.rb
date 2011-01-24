require 'spec_helper'

describe Generator::Literal, '#visit_time' do
  subject { object.visit_time(time) }

  let(:klass)  { Class.new(Visitor) { include Generator::Literal } }
  let(:object) { klass.new                                         }

  before :all do
    @original_tz = ENV['TZ']
  end

  after :all do
    ENV['TZ'] = @original_tz
  end

  context 'when the Time is UTC' do
    context 'and the microseconds are equal to 0' do
      let(:usec) { 0                                        }
      let(:time) { Time.utc(2010, 12, 31, 23, 59, 59, usec) }

      it_should_behave_like 'a generated SQL expression'

      it { should == "'2010-12-31T23:59:59+00:00'" }
    end

    context 'and the microseconds are greater than 0' do
      let(:usec) { 1                                        }
      let(:time) { Time.utc(2010, 12, 31, 23, 59, 59, usec) }

      it_should_behave_like 'a generated SQL expression'

      it { should == "'2010-12-31T23:59:59.000001+00:00'" }
    end
  end

  context 'when the Time is local, and the local time zone is UTC' do
    before :all do
      ENV['TZ'] = 'UTC'
    end

    context 'and the microseconds are equal to 0' do
      let(:usec) { 0                                          }
      let(:time) { Time.local(2010, 12, 31, 23, 59, 59, usec) }

      it_should_behave_like 'a generated SQL expression'

      it { should == "'2010-12-31T23:59:59+00:00'" }
    end

    context 'and the microseconds are greater than 0' do
      let(:usec) { 1                                          }
      let(:time) { Time.local(2010, 12, 31, 23, 59, 59, usec) }

      it_should_behave_like 'a generated SQL expression'

      it { should == "'2010-12-31T23:59:59.000001+00:00'" }
    end
  end

  context 'when the Time is local, and the local time zone is not UTC' do
    before :all do
      ENV['TZ'] = 'America/Vancouver'
    end

    context 'and the microseconds are equal to 0' do
      let(:usec) { 0                                          }
      let(:time) { Time.local(2010, 12, 31, 15, 59, 59, usec) }

      it_should_behave_like 'a generated SQL expression'

      it { should == "'2010-12-31T23:59:59+00:00'" }
    end

    context 'and the microseconds are greater than 0' do
      let(:usec) { 1                                          }
      let(:time) { Time.local(2010, 12, 31, 15, 59, 59, usec) }

      it_should_behave_like 'a generated SQL expression'

      it { should == "'2010-12-31T23:59:59.000001+00:00'" }
    end
  end
end
