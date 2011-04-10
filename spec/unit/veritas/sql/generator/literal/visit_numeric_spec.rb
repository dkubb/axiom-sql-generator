# encoding: utf-8

require 'spec_helper'

describe SQL::Generator::Literal, '#visit_numeric' do
  subject { object.visit_numeric(numeric) }

  let(:described_class) { Class.new(SQL::Generator::Visitor) { include SQL::Generator::Literal } }
  let(:object)          { described_class.new                                                    }

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
