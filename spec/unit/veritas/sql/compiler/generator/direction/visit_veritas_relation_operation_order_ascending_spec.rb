# encoding: utf-8

require 'spec_helper'

describe SQL::Compiler::Generator::Direction, '#visit_veritas_relation_operation_order_ascending' do
  subject { object.visit_veritas_relation_operation_order_ascending(direction) }

  let(:described_class) { Class.new(SQL::Compiler::Visitor) { include SQL::Compiler::Generator::Direction } }
  let(:direction)       { Attribute::Integer.new(:id).asc                                                   }
  let(:object)          { described_class.new                                                               }

  it_should_behave_like 'a generated SQL expression'

  its(:to_s) { should eql('"id"') }
end
