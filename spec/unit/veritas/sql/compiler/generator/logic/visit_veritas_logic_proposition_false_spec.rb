require 'spec_helper'

describe Generator::Logic, '#visit_veritas_logic_proposition_false' do
  subject { object.visit_veritas_logic_proposition_false(false_proposition) }

  let(:described_class)   { Class.new(Visitor) { include Generator::Logic } }
  let(:false_proposition) { Logic::Proposition::False.instance              }
  let(:object)            { described_class.new                             }

  it_should_behave_like 'a generated SQL expression'

  its(:to_s) { should eql('1 = 0') }
end
