require 'spec_helper'

describe Generator::Literal, '#visit_numeric' do
  subject { object.visit_numeric(numeric) }

  let(:klass)  { Class.new(Visitor) { include Generator::Literal } }
  let(:object) { klass.new                                         }

  context 'with an Integer' do
    let(:numeric) { 1 }

    it_should_behave_like 'a generated SQL expression'

    its(:to_s) { should eql('1') }
  end

  context 'with a Float' do
    let(:numeric) { 1.0 }

    it_should_behave_like 'a generated SQL expression'

    its(:to_s) { should eql('1.0') }
  end

  context 'with a BigDecimal' do
    let(:numeric) { BigDecimal('1.0') }

    it_should_behave_like 'a generated SQL expression'

    its(:to_s) { should eql('0.1E1') }
  end
end
