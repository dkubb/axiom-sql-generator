# encoding: utf-8

require 'spec_helper'

describe SQL::Generator, '.parenthesize!' do
  subject { object.parenthesize!(string) }

  let(:string) { '1 + 1'                    }
  let(:object) { self.class.described_class }

  it_should_behave_like 'a generated SQL expression'

  it 'modifies the string inline' do
    should equal(string)
  end

  its(:to_s) { should == '(1 + 1)' }
end
