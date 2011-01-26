require 'spec_helper'

describe Generator::Logic, '#visit_veritas_logic_connective_negation' do
  subject { object.visit_veritas_logic_connective_negation(negation) }

  let(:klass)     { Class.new(Visitor) { include Generator::Logic }  }
  let(:attribute) { Attribute::Integer.new(:id)                      }
  let(:negation)  { Logic::Connective::Negation.new(attribute.eq(1)) }
  let(:object)    { klass.new                                        }

  before do
    object.instance_variable_set(:@name, 'users')
  end

  it_should_behave_like 'a generated SQL expression'

  it { should == 'NOT "users"."id" = 1' }
end
