require 'spec_helper'

describe Generator::BinaryRelation, '#visit_veritas_algebra_intersection' do
  subject { object.visit_veritas_algebra_intersection(intersection) }

  let(:id)            { Attribute::Integer.new(:id)                      }
  let(:name)          { Attribute::String.new(:name)                     }
  let(:age)           { Attribute::Integer.new(:age, :required => false) }
  let(:header)        { [ id, name, age ]                                }
  let(:body)          { [ [ 1, 'Dan Kubb', 35 ] ].each                   }
  let(:base_relation) { BaseRelation.new('users', header, body)          }
  let(:intersection)  { operand.intersect(operand)                       }
  let(:object)        { described_class.new                              }

  context 'when the operand is a base relation' do
    let(:operand) { base_relation }

    it_should_behave_like 'a generated SQL SELECT query'

    its(:to_s) { should eql('SELECT "id", "name", "age" FROM "users" INTERSECT SELECT "id", "name", "age" FROM "users"') }
  end

  context 'when the operand is a projection' do
    let(:operand) { base_relation.project([ :id, :name ]) }

    it_should_behave_like 'a generated SQL SELECT query'

    its(:to_s) { should eql('SELECT DISTINCT "id", "name" FROM "users" INTERSECT SELECT DISTINCT "id", "name" FROM "users"') }
  end

  context 'when the operand is a rename' do
    let(:operand) { base_relation.rename(:id => :user_id) }

    it_should_behave_like 'a generated SQL SELECT query'

    its(:to_s) { should eql('SELECT "id" AS "user_id", "name", "age" FROM "users" INTERSECT SELECT "id" AS "user_id", "name", "age" FROM "users"') }
  end

  context 'when the operand is a restriction' do
    let(:operand) { base_relation.restrict { |r| r[:id].eq(1) } }

    it_should_behave_like 'a generated SQL SELECT query'

    its(:to_s) { should eql('SELECT "id", "name", "age" FROM "users" WHERE "id" = 1 INTERSECT SELECT "id", "name", "age" FROM "users" WHERE "id" = 1') }
  end

  context 'when the operand is ordered' do
    let(:operand) { base_relation.order }

    it_should_behave_like 'a generated SQL SELECT query'

    its(:to_s) { should eql('SELECT "id", "name", "age" FROM "users" ORDER BY "id", "name", "age" INTERSECT SELECT "id", "name", "age" FROM "users" ORDER BY "id", "name", "age"') }
  end

  context 'when the operand is reversed' do
    let(:operand) { base_relation.order.reverse }

    it_should_behave_like 'a generated SQL SELECT query'

    its(:to_s) { should eql('SELECT "id", "name", "age" FROM "users" ORDER BY "id" DESC, "name" DESC, "age" DESC INTERSECT SELECT "id", "name", "age" FROM "users" ORDER BY "id" DESC, "name" DESC, "age" DESC') }
  end

  context 'when the operand is limited' do
    let(:operand) { base_relation.order.take(1) }

    it_should_behave_like 'a generated SQL SELECT query'

    its(:to_s) { should eql('SELECT "id", "name", "age" FROM "users" ORDER BY "id", "name", "age" LIMIT 1 INTERSECT SELECT "id", "name", "age" FROM "users" ORDER BY "id", "name", "age" LIMIT 1') }
  end

  context 'when the operand is offset' do
    let(:operand) { base_relation.order.drop(1) }

    it_should_behave_like 'a generated SQL SELECT query'

    its(:to_s) { should eql('SELECT "id", "name", "age" FROM "users" ORDER BY "id", "name", "age" OFFSET 1 INTERSECT SELECT "id", "name", "age" FROM "users" ORDER BY "id", "name", "age" OFFSET 1') }
  end
end
