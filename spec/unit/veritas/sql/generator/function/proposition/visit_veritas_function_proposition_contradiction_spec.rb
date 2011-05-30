# encoding: utf-8

require 'spec_helper'

describe SQL::Generator::Function::Proposition, '#visit_veritas_function_proposition_contradiction' do
  subject { object.visit_veritas_function_proposition_contradiction(contradiction) }

  let(:described_class) { Class.new(SQL::Generator::Visitor) { include SQL::Generator::Function::Proposition } }
  let(:contradiction)   { Function::Proposition::Contradiction.instance                                        }
  let(:object)          { described_class.new                                                                  }

  it_should_behave_like 'a generated SQL expression'

  its(:to_s) { should eql('FALSE') }
end
