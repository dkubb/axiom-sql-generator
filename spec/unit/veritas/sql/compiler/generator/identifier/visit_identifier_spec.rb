require 'spec_helper'

describe Generator::Identifier, '#visit_identifier' do
  subject { object.visit_identifier(identifier) }

  let(:klass)  { Class.new(Visitor) { include Generator::Identifier } }
  let(:object) { klass.new                                            }

  context 'with an identifer containing no quotes' do
    let(:identifier) { 'users' }

    it_should_behave_like 'a generated SQL expression'

    it { should == '"users"' }
  end

  context 'with an identifer containing quotes' do
    let(:identifier) { 'users"name' }

    it_should_behave_like 'a generated SQL expression'

    it { should == '"users""name"' }
  end
end
