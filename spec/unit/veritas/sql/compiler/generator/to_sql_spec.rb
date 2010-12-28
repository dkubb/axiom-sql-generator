require 'spec_helper'

describe Generator, '#to_sql' do
  subject { object.to_sql }

  let(:klass)  { Generator }
  let(:object) { klass.new }

  it_should_behave_like 'an idempotent method'

  it { should == '' }
end
