# encoding: utf-8

require 'spec_helper'

describe SQL::Compiler::Generator::Literal, '#visit_string' do
  subject { object.visit_string(string) }

  let(:described_class) { Class.new(SQL::Compiler::Visitor) { include SQL::Compiler::Generator::Literal } }
  let(:object)          { described_class.new                                                             }

  context 'with a string containing no quotes' do
    let(:string) { 'string'.freeze }

    it_should_behave_like 'a generated SQL expression'

    its(:to_s) { should eql("'string'") }
  end

  context 'with a string containing quotes' do
    let(:string) { "string'name".freeze }

    it_should_behave_like 'a generated SQL expression'

    its(:to_s) { should eql("'string''name'") }
  end
end
