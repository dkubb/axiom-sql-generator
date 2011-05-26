# encoding: utf-8

require 'spec_helper'

describe DateTime, '#iso8601' do

  # ruby 1.9.3 has problems with fractional nanoseconds
  def self.it_supports_nanoseconds(message = 'returns the expected date-time', &block)
    if RUBY_VERSION >= '1.9.3'
      it(message) { pending('Fix rounding error in 1.9.3', &block) }
    else
      it(message, &block)
    end
  end

  let(:object)          { described_class.new(2010, 12, 31, 23, 59, 59 + nsec_in_seconds) }
  let(:nsec_in_seconds) { 1 - Rational(1, 10**9)                                          }

  # rubinius 1.2.3 has problems with fractional seconds above 59
  unless defined?(RUBY_ENGINE) && RUBY_ENGINE == 'rbx' && Rubinius::VERSION <= '1.2.3'
    context 'with no arguments' do
      subject { object.iso8601 }

      context 'when the datetime is frozen' do
        before do
          object.freeze
        end

        it { should respond_to(:to_s) }

        it_supports_nanoseconds do
          should == '2010-12-31T23:59:59+00:00'
        end
      end

      context 'when the datetime is not frozen' do
        it { should respond_to(:to_s) }

        it { should == '2010-12-31T23:59:59+00:00' }
      end
    end

    context 'with a time scale of 0' do
      subject { object.iso8601(time_scale) }

      let(:time_scale) { 0 }

      context 'when the datetime is frozen' do
        before do
          object.freeze
        end

        it { should respond_to(:to_s) }

        it_supports_nanoseconds do
          should == '2010-12-31T23:59:59+00:00'
        end
      end

      context 'when the datetime is not frozen' do
        it { should respond_to(:to_s) }

        it { should == '2010-12-31T23:59:59+00:00' }
      end
    end

    context 'with a time scale of 1' do
      subject { object.iso8601(time_scale) }

      let(:time_scale) { 1 }

      context 'when the datetime is frozen' do
        before do
          object.freeze
        end

        it { should respond_to(:to_s) }

        it_supports_nanoseconds do
          should == '2010-12-31T23:59:59.9+00:00'
        end
      end

      context 'when the datetime is not frozen' do
        it { should respond_to(:to_s) }

        it { should == '2010-12-31T23:59:59.9+00:00' }
      end
    end

    context 'with a time scale of 9' do
      subject { object.iso8601(time_scale) }

      let(:time_scale) { 9 }

      context 'when the datetime is frozen' do
        before do
          object.freeze
        end

        it { should respond_to(:to_s) }

        it_supports_nanoseconds do
          should == '2010-12-31T23:59:59.999999999+00:00'
        end
      end

      context 'when the datetime is not frozen' do
        it { should respond_to(:to_s) }

        it { should == '2010-12-31T23:59:59.999999999+00:00' }
      end
    end
  end
end
