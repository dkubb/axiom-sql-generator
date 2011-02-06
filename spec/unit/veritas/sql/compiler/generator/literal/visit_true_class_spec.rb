require 'spec_helper'

describe Generator::Literal, '#visit_true_class' do
  subject { object.visit_true_class(true) }

  let(:described_class) { Class.new(Visitor) { include Generator::Literal } }
  let(:object)          { described_class.new                               }

  it_should_behave_like 'a generated SQL expression'

  its(:to_s) { should eql('TRUE') }
end
