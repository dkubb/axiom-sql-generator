# encoding: utf-8

require 'spec_helper'

describe SQL::Generator::Function::Proposition, '#visit_axiom_function_proposition_tautology' do
  subject { object.visit_axiom_function_proposition_tautology(tautology) }

  let(:described_class) { Class.new(SQL::Generator::Visitor) { include SQL::Generator::Function::Proposition } }
  let(:tautology)       { Function::Proposition::Tautology.instance                                            }
  let(:object)          { described_class.new                                                                  }

  it_should_behave_like 'a generated SQL expression'

  its(:to_s) { should eql('TRUE') }
end
