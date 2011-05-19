# encoding: utf-8

require 'spec_helper'

describe Date, '#iso8601' do
  subject { object.iso8601 }

  context 'when the date is frozen' do
    let(:object) { described_class.new(2010, 12, 31).freeze }

    it { should respond_to(:to_s) }

    it { should == '2010-12-31' }
  end

  context 'when the date is not frozen' do
    let(:object) { described_class.new(2010, 12, 31) }

    it { should respond_to(:to_s) }

    it { should == '2010-12-31' }
  end
end
