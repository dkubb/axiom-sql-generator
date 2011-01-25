require 'spec_helper'

describe Generator::Literal, '#visit_string' do
  subject { object.visit_string(string) }

  let(:klass)  { Class.new(Visitor) { include Generator::Literal } }
  let(:object) { klass.new                                         }

  context 'with a string containing no quotes' do
    let(:string) { 'string'.freeze }

    it_should_behave_like 'a generated SQL expression'

    it { should == "'string'" }
  end

  context 'with a string containing quotes' do
    let(:string) { "string'name".freeze }

    it_should_behave_like 'a generated SQL expression'

    it { should == "'string''name'" }
  end
end
