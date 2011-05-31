# encoding: utf-8

require 'spec_helper'

describe SQL::Generator::Function::Aggregate, '#visit_veritas_aggregate_variance' do
  subject { object.visit_veritas_aggregate_variance(variance) }

  let(:described_class) { Class.new(SQL::Generator::Visitor) { include SQL::Generator::Function::Aggregate } }
  let(:attribute)       { Attribute::Integer.new(:id)                                                        }
  let(:variance)        { attribute.variance                                                                 }
  let(:object)          { described_class.new                                                                }

  it_should_behave_like 'a generated SQL expression'

  its(:to_s) { should eql('VAR_POP ("id")') }
end
