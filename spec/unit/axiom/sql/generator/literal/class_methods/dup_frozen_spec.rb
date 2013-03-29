# encoding: utf-8

require 'spec_helper'

describe SQL::Generator::Literal, '.dup_frozen' do
  subject { object.dup_frozen(object_arg) }

  let(:object) { SQL::Generator::Literal }

  context 'with a frozen object' do
    let(:object_arg) { Time.now.freeze }

    it { should_not equal(object_arg) }

    it { should == object_arg }
  end

  context 'with a non-frozen object' do
    let(:object_arg) { Time.now }

    it { should equal(object_arg) }
  end
end
