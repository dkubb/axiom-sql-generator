# encoding: utf-8

require 'spec_helper'

describe SQL::Generator::Function::Aggregate, '#visit_veritas_aggregate_standard_deviation' do
  subject { object.visit_veritas_aggregate_standard_deviation(standard_deviation) }

  let(:described_class)    { Class.new(SQL::Generator::Visitor) { include SQL::Generator::Function::Aggregate } }
  let(:attribute)          { Attribute::Integer.new(:id)                                                        }
  let(:standard_deviation) { attribute.standard_deviation                                                       }
  let(:object)             { described_class.new                                                                }

  it_should_behave_like 'a generated SQL expression'

  its(:to_s) { should eql('COALESCE (STDDEV_POP ("id"), 0.0)') }
end
