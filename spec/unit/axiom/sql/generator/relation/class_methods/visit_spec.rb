# encoding: utf-8

require 'spec_helper'

describe SQL::Generator::Relation, '.visit' do
  subject { object.visit(relation) }

  let(:id)            { Attribute::Integer.new(:id)                      }
  let(:name)          { Attribute::String.new(:name)                     }
  let(:age)           { Attribute::Integer.new(:age, :required => false) }
  let(:header)        { [ id, name, age ]                                }
  let(:body)          { [ [ 1, 'Dan Kubb', 35 ] ].each                   }
  let(:base_relation) { Relation::Base.new('users', header, body)        }
  let(:object)        { described_class                                  }

  context 'when the relation is an insertion operation' do
    let(:relation) { base_relation.insert(base_relation) }

    it { should be_kind_of(SQL::Generator::Relation::Insertion) }

    its(:name) { should == 'users' }

    it { should be_frozen }
  end

  context 'when the relation is a set operation' do
    let(:relation) { base_relation.union(base_relation) }

    it { should be_kind_of(SQL::Generator::Relation::Set) }

    its(:name) { should == 'users' }

    it { should be_frozen }
  end

  context 'when the relation is a binary operation' do
    let(:relation) { base_relation.join(base_relation.project([ :id ])) }

    it { should be_kind_of(SQL::Generator::Relation::Binary) }

    its(:name) { should == 'users' }

    it { should be_frozen }
  end

  context 'when the relation is a unary operation' do
    let(:relation) { base_relation.project([ :id ]) }

    it { should be_kind_of(SQL::Generator::Relation::Unary) }

    its(:name) { should == 'users' }

    it { should be_frozen }
  end

  context 'when the relation is a base relation' do
    let(:relation) { base_relation }

    it { should be_kind_of(SQL::Generator::Relation::Base) }

    its(:name) { should == 'users' }

    it { should be_frozen }
  end

  context 'when the relation is invalid' do
    let(:relation) { double('Invalid Relation') }

    specify { expect { subject }.to raise_error(SQL::Generator::InvalidRelationError, "#{relation.class} is not a visitable relation") }
  end
end
