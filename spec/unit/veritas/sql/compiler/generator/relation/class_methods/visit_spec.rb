require 'spec_helper'

describe SQL::Compiler::Generator::Relation, '.visit' do
  subject { object.visit(relation) }

  let(:id)            { Attribute::Integer.new(:id)                      }
  let(:name)          { Attribute::String.new(:name)                     }
  let(:age)           { Attribute::Integer.new(:age, :required => false) }
  let(:header)        { [ id, name, age ]                                }
  let(:body)          { [ [ 1, 'Dan Kubb', 35 ] ].each                   }
  let(:base_relation) { BaseRelation.new('users', header, body)          }
  let(:object)        { described_class                                  }

  context 'when the relation is a set operation' do
    let(:relation) { base_relation.union(base_relation) }

    it { should be_kind_of(SQL::Compiler::Generator::Relation::Set) }

    its(:name) { should == 'users' }

    it { should be_frozen }
  end

  context 'when the relation is a binary operation' do
    let(:relation) { base_relation.join(base_relation.project([ :id ])) }

    it { should be_kind_of(SQL::Compiler::Generator::Relation::Binary) }

    its(:name) { should == 'users' }

    it { should be_frozen }
  end

  context 'when the relation is a unary operation' do
    let(:relation) { base_relation.project([ :id ]) }

    it { should be_kind_of(SQL::Compiler::Generator::Relation::Unary) }

    its(:name) { should == 'users' }

    it { should be_frozen }
  end

  context 'when the relation is a base relation' do
    let(:relation) { base_relation }

    it { should be_kind_of(SQL::Compiler::Generator::Relation::Base) }

    its(:name) { should == 'users' }

    it { should be_frozen }
  end

  context 'when the relation is invalid' do
    let(:relation) { mock('Invalid Relation') }

    specify { expect { subject }.to raise_error(SQL::Compiler::InvalidRelationError, "#{relation.class} is not a visitable relation") }
  end
end
