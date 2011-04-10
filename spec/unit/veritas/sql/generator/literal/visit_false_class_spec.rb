# encoding: utf-8

require 'spec_helper'

describe SQL::Generator::Literal, '#visit_false_class' do
  subject { object.visit_false_class(false) }

  let(:described_class) { Class.new(SQL::Generator::Visitor) { include SQL::Generator::Literal } }
  let(:object)          { described_class.new                                                    }

  it_should_behave_like 'a generated SQL expression'

  its(:to_s) { should eql('FALSE') }
end
