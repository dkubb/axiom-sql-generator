# encoding: utf-8

require 'spec_helper'

describe SQL::Compiler::Generator::Literal, '#visit_true_class' do
  subject { object.visit_true_class(true) }

  let(:described_class) { Class.new(SQL::Compiler::Visitor) { include SQL::Compiler::Generator::Literal } }
  let(:object)          { described_class.new                                                             }

  it_should_behave_like 'a generated SQL expression'

  its(:to_s) { should eql('TRUE') }
end
