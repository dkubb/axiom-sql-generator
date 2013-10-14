# encoding: utf-8

require 'spec_helper'

describe SQL::Generator::Relation::Set, '.normalize_operand_headers' do
  subject { object.normalize_operand_headers(relation) }

  let(:object)        { described_class                   }
  let(:relation)      { left.union(right)                 }
  let(:relation_name) { 'test'                            }
  let(:header)        { [[:id, Integer], [:name, String]] }
  let(:body)          { [].each                           }

  context 'when the left and right headers are sorted in the same order' do
    let(:left)  { Relation::Base.new(relation_name, header, body) }
    let(:right) { Relation::Base.new(relation_name, header, body) }

    it { should equal(relation) }
  end

  context 'when the left and right headers are sorted in different order' do
    let(:left)  { Relation::Base.new(relation_name, header,         body) }
    let(:right) { Relation::Base.new(relation_name, header.reverse, body) }

    it { should_not equal(relation) }

    its(:right) { should_not equal(right) }

    it { should be_kind_of(relation.class) }

    its(:left) { should equal(left) }

    its(:right) { should eql(right.project(header)) }
  end
end
