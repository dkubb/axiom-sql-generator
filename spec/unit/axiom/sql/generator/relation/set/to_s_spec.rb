# encoding: utf-8

require 'spec_helper'

describe SQL::Generator::Relation::Set, '#to_s' do
  subject { object.to_s }

  let(:id)            { Attribute::Integer.new(:id)                      }
  let(:name)          { Attribute::String.new(:name)                     }
  let(:age)           { Attribute::Integer.new(:age, :required => false) }
  let(:header)        { [ id, name, age ]                                }
  let(:body)          { [ [ 1, 'Dan Kubb', 35 ] ].each                   }
  let(:base_relation) { Relation::Base.new('users', header, body)        }
  let(:object)        { described_class.new                              }

  context 'when no object visited' do
    it_should_behave_like 'an idempotent method'

    it { should respond_to(:to_s) }

    it { should be_frozen }

    its(:to_s) { should == '' }
  end

  context 'when a difference is visited' do
    before do
      object.visit(base_relation.difference(base_relation))
    end

    it_should_behave_like 'a generated SQL expression'

    its(:to_s) { should eql('(SELECT "id", "name", "age" FROM "users") EXCEPT (SELECT "id", "name", "age" FROM "users")') }
  end

  context 'when an intersection is visited' do
    before do
      object.visit(base_relation.intersect(base_relation))
    end

    it_should_behave_like 'a generated SQL expression'

    its(:to_s) { should eql('(SELECT "id", "name", "age" FROM "users") INTERSECT (SELECT "id", "name", "age" FROM "users")') }
  end

  context 'when a union is visited' do
    before do
      object.visit(base_relation.union(base_relation))
    end

    it_should_behave_like 'a generated SQL expression'

    its(:to_s) { should eql('(SELECT "id", "name", "age" FROM "users") UNION (SELECT "id", "name", "age" FROM "users")') }
  end
end
