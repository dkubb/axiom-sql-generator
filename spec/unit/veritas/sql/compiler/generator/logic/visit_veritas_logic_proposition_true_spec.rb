require 'spec_helper'

describe Generator::Logic, '#visit_veritas_logic_proposition_true' do
  subject { object.visit_veritas_logic_proposition_true(true_proposition) }

  let(:klass)            { Class.new(Visitor) { include Generator::Logic } }
  let(:true_proposition) { Logic::Proposition::True.instance               }
  let(:object)           { klass.new                                       }

  it_should_behave_like 'a generated SQL expression'

  its(:to_s) { should eql('1 = 1') }
end
