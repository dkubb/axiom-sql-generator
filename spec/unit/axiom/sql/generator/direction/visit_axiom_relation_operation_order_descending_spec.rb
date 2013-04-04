# encoding: utf-8

require 'spec_helper'

describe SQL::Generator::Direction, '#visit_axiom_relation_operation_order_descending' do
  subject { object.visit_axiom_relation_operation_order_descending(direction) }

  let(:described_class) { Class.new(SQL::Generator::Visitor) { include SQL::Generator::Direction } }
  let(:direction)       { Attribute::Integer.new(:id).desc                                         }
  let(:object)          { described_class.new                                                      }

  it_should_behave_like 'a generated SQL expression'

  its(:to_s) { should eql('"id" DESC') }
end
