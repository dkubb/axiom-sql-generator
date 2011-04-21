# encoding: utf-8

require 'spec_helper'

describe SQL::Generator::Logic, '#visit_veritas_logic_proposition_contradiction' do
  subject { object.visit_veritas_logic_proposition_contradiction(contradiction) }

  let(:described_class) { Class.new(SQL::Generator::Visitor) { include SQL::Generator::Logic } }
  let(:contradiction)   { Logic::Proposition::Contradiction.instance                           }
  let(:object)          { described_class.new                                                  }

  it_should_behave_like 'a generated SQL expression'

  its(:to_s) { should eql('1 = 0') }
end
