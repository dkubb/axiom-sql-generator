# encoding: utf-8

require 'spec_helper'

describe SQL::Generator::Function::String, '#visit_veritas_function_string_length' do
  subject { object.visit_veritas_function_string_length(length) }

  let(:described_class) { Class.new(SQL::Generator::Visitor) { include SQL::Generator::Function::String } }
  let(:length)          { Attribute::String.new(:name).length                                             }
  let(:object)          { described_class.new                                                             }

  it_should_behave_like 'a generated SQL expression'

  its(:to_s) { should eql('LENGTH ("name")') }
end
