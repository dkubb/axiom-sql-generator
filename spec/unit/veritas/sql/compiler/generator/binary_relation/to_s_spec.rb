require 'spec_helper'

describe Generator::BinaryRelation, '#to_s' do
  subject { object.to_s }

  let(:object) { described_class.new }

  context 'when no object visited' do
    it_should_behave_like 'an idempotent method'

    it { should respond_to(:to_s) }

    it { should be_frozen }

    its(:to_s) { should == '' }
  end
end
