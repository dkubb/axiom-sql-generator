# encoding: utf-8

require 'spec_helper'

describe SQL::Generator::Function::Aggregate, '#visit_veritas_aggregate_count' do
  subject { object.visit_veritas_aggregate_count(count) }

  let(:described_class) { Class.new(SQL::Generator::Visitor) { include SQL::Generator::Function::Aggregate } }
  let(:attribute)       { Attribute::Integer.new(:id)                                                        }
  let(:count)           { attribute.count                                                                    }
  let(:object)          { described_class.new                                                                }

  it_should_behave_like 'a generated SQL expression'

  its(:to_s) { should eql('COALESCE (COUNT ("id"), 0)') }
end
