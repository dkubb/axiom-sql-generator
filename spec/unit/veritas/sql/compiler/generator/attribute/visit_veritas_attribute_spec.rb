require 'spec_helper'

describe Generator::Attribute, '#visit_veritas_attribute' do
  subject { object.visit_veritas_attribute(attribute) }

  let(:klass)     { Class.new(Visitor) { include Generator::Attribute } }
  let(:attribute) { Attribute::Integer.new(:id)                         }
  let(:object)    { klass.new                                           }

  before do
    object.instance_variable_set(:@name, 'users')
  end

  it_should_behave_like 'a generated SQL expression'

  it { should == '"users"."id"' }
end
