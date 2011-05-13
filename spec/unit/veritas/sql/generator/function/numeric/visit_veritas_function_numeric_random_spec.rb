# encoding: utf-8

require 'spec_helper'

describe SQL::Generator::Function::Numeric, '#visit_veritas_function_numeric_random' do
  subject { object.visit_veritas_function_numeric_random(random) }

  let(:described_class) { Class.new(SQL::Generator::Visitor) { include SQL::Generator::Function::Numeric } }
  let(:random)          { Attribute::Integer.new(:number).random                                           }
  let(:object)          { described_class.new                                                              }

  it_should_behave_like 'a generated SQL expression'

  its(:to_s) { should eql('RANDOM ()') }
end
