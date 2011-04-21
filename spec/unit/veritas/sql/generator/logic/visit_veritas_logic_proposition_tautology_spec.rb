# encoding: utf-8

require 'spec_helper'

describe SQL::Generator::Logic, '#visit_veritas_logic_proposition_tautology' do
  subject { object.visit_veritas_logic_proposition_tautology(tautology) }

  let(:described_class) { Class.new(SQL::Generator::Visitor) { include SQL::Generator::Logic } }
  let(:tautology)       { Logic::Proposition::Tautology.instance                               }
  let(:object)          { described_class.new                                                  }

  it_should_behave_like 'a generated SQL expression'

  its(:to_s) { should eql('1 = 1') }
end
