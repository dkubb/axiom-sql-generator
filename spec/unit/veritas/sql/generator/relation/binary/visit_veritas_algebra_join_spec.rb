# encoding: utf-8

require 'spec_helper'

describe SQL::Generator::Relation::Binary, '#visit_veritas_algebra_join' do
  subject { object.visit_veritas_algebra_join(join) }

  let(:relation_name) { 'users'                                          }
  let(:id)            { Attribute::Integer.new(:id)                      }
  let(:name)          { Attribute::String.new(:name)                     }
  let(:age)           { Attribute::Integer.new(:age, :required => false) }
  let(:header)        { [ id, name, age ]                                }
  let(:body)          { [ [ 1, 'Dan Kubb', 35 ] ].each                   }
  let(:base_relation) { BaseRelation.new(relation_name, header, body)    }
  let(:left)          { operand                                          }
  let(:right)         { operand                                          }
  let(:join)          { left.join(right)                                 }
  let(:object)        { described_class.new                              }

  context 'when the operands are base relations' do
    let(:operand) { base_relation }

    it_should_behave_like 'a generated SQL SELECT query'

    its(:to_s)        { should eql('SELECT "id", "name", "age" FROM "users" NATURAL JOIN "users"') }
    its(:to_subquery) { should eql('SELECT * FROM "users" NATURAL JOIN "users"') }
  end

  context 'when the operands are projections' do
    let(:operand) { base_relation.project([ :id, :name ]) }

    it_should_behave_like 'a generated SQL SELECT query'

    its(:to_s)        { should eql('SELECT "id", "name" FROM (SELECT DISTINCT "id", "name" FROM "users") AS "left" NATURAL JOIN (SELECT DISTINCT "id", "name" FROM "users") AS "right"') }
    its(:to_subquery) { should eql('SELECT * FROM (SELECT DISTINCT "id", "name" FROM "users") AS "left" NATURAL JOIN (SELECT DISTINCT "id", "name" FROM "users") AS "right"') }
  end

  context 'when the operands are rename' do
    let(:operand) { base_relation.rename(:id => :user_id) }

    it_should_behave_like 'a generated SQL SELECT query'

    its(:to_s)        { should eql('SELECT "user_id", "name", "age" FROM (SELECT "id" AS "user_id", "name", "age" FROM "users") AS "left" NATURAL JOIN (SELECT "id" AS "user_id", "name", "age" FROM "users") AS "right"') }
    its(:to_subquery) { should eql('SELECT * FROM (SELECT "id" AS "user_id", "name", "age" FROM "users") AS "left" NATURAL JOIN (SELECT "id" AS "user_id", "name", "age" FROM "users") AS "right"') }
  end

  context 'when the operands are restrictions' do
    let(:operand) { base_relation.restrict { |r| r[:id].eq(1) } }

    it_should_behave_like 'a generated SQL SELECT query'

    its(:to_s)        { should eql('SELECT "id", "name", "age" FROM (SELECT * FROM "users" WHERE "id" = 1) AS "left" NATURAL JOIN (SELECT * FROM "users" WHERE "id" = 1) AS "right"') }
    its(:to_subquery) { should eql('SELECT * FROM (SELECT * FROM "users" WHERE "id" = 1) AS "left" NATURAL JOIN (SELECT * FROM "users" WHERE "id" = 1) AS "right"') }
  end

  context 'when the operands are ordered' do
    let(:operand) { base_relation.order }

    it_should_behave_like 'a generated SQL SELECT query'

    its(:to_s)        { should eql('SELECT "id", "name", "age" FROM (SELECT * FROM "users" ORDER BY "id", "name", "age") AS "left" NATURAL JOIN (SELECT * FROM "users" ORDER BY "id", "name", "age") AS "right"') }
    its(:to_subquery) { should eql('SELECT * FROM (SELECT * FROM "users" ORDER BY "id", "name", "age") AS "left" NATURAL JOIN (SELECT * FROM "users" ORDER BY "id", "name", "age") AS "right"') }
  end

  context 'when the operands are reversed' do
    let(:operand) { base_relation.order.reverse }

    it_should_behave_like 'a generated SQL SELECT query'

    its(:to_s)        { should eql('SELECT "id", "name", "age" FROM (SELECT * FROM "users" ORDER BY "id" DESC, "name" DESC, "age" DESC) AS "left" NATURAL JOIN (SELECT * FROM "users" ORDER BY "id" DESC, "name" DESC, "age" DESC) AS "right"') }
    its(:to_subquery) { should eql('SELECT * FROM (SELECT * FROM "users" ORDER BY "id" DESC, "name" DESC, "age" DESC) AS "left" NATURAL JOIN (SELECT * FROM "users" ORDER BY "id" DESC, "name" DESC, "age" DESC) AS "right"') }
  end

  context 'when the operands are limited' do
    let(:operand) { base_relation.order.take(1) }

    it_should_behave_like 'a generated SQL SELECT query'

    its(:to_s)        { should eql('SELECT "id", "name", "age" FROM (SELECT * FROM "users" ORDER BY "id", "name", "age" LIMIT 1) AS "left" NATURAL JOIN (SELECT * FROM "users" ORDER BY "id", "name", "age" LIMIT 1) AS "right"') }
    its(:to_subquery) { should eql('SELECT * FROM (SELECT * FROM "users" ORDER BY "id", "name", "age" LIMIT 1) AS "left" NATURAL JOIN (SELECT * FROM "users" ORDER BY "id", "name", "age" LIMIT 1) AS "right"') }
  end

  context 'when the operands are offsets' do
    let(:operand) { base_relation.order.drop(1) }

    it_should_behave_like 'a generated SQL SELECT query'

    its(:to_s)        { should eql('SELECT "id", "name", "age" FROM (SELECT * FROM "users" ORDER BY "id", "name", "age" OFFSET 1) AS "left" NATURAL JOIN (SELECT * FROM "users" ORDER BY "id", "name", "age" OFFSET 1) AS "right"') }
    its(:to_subquery) { should eql('SELECT * FROM (SELECT * FROM "users" ORDER BY "id", "name", "age" OFFSET 1) AS "left" NATURAL JOIN (SELECT * FROM "users" ORDER BY "id", "name", "age" OFFSET 1) AS "right"') }
  end

  context 'when the operands are differences' do
    let(:operand) { base_relation.difference(base_relation) }

    it_should_behave_like 'a generated SQL SELECT query'

    its(:to_s)        { should eql('SELECT "id", "name", "age" FROM ((SELECT * FROM "users") EXCEPT (SELECT * FROM "users")) AS "left" NATURAL JOIN ((SELECT * FROM "users") EXCEPT (SELECT * FROM "users")) AS "right"') }
    its(:to_subquery) { should eql('SELECT * FROM ((SELECT * FROM "users") EXCEPT (SELECT * FROM "users")) AS "left" NATURAL JOIN ((SELECT * FROM "users") EXCEPT (SELECT * FROM "users")) AS "right"') }
  end

  context 'when the operands are intersections' do
    let(:operand) { base_relation.intersect(base_relation) }

    it_should_behave_like 'a generated SQL SELECT query'

    its(:to_s)        { should eql('SELECT "id", "name", "age" FROM ((SELECT * FROM "users") INTERSECT (SELECT * FROM "users")) AS "left" NATURAL JOIN ((SELECT * FROM "users") INTERSECT (SELECT * FROM "users")) AS "right"') }
    its(:to_subquery) { should eql('SELECT * FROM ((SELECT * FROM "users") INTERSECT (SELECT * FROM "users")) AS "left" NATURAL JOIN ((SELECT * FROM "users") INTERSECT (SELECT * FROM "users")) AS "right"') }
  end

  context 'when the operands are unions' do
    let(:operand) { base_relation.union(base_relation) }

    it_should_behave_like 'a generated SQL SELECT query'

    its(:to_s)        { should eql('SELECT "id", "name", "age" FROM ((SELECT * FROM "users") UNION (SELECT * FROM "users")) AS "left" NATURAL JOIN ((SELECT * FROM "users") UNION (SELECT * FROM "users")) AS "right"') }
    its(:to_subquery) { should eql('SELECT * FROM ((SELECT * FROM "users") UNION (SELECT * FROM "users")) AS "left" NATURAL JOIN ((SELECT * FROM "users") UNION (SELECT * FROM "users")) AS "right"') }
  end

  context 'when the operands are joins' do
    let(:operand) { base_relation.join(base_relation) }

    it_should_behave_like 'a generated SQL SELECT query'

    its(:to_s)        { should eql('SELECT "id", "name", "age" FROM (SELECT * FROM "users" NATURAL JOIN "users") AS "left" NATURAL JOIN (SELECT * FROM "users" NATURAL JOIN "users") AS "right"') }
    its(:to_subquery) { should eql('SELECT * FROM (SELECT * FROM "users" NATURAL JOIN "users") AS "left" NATURAL JOIN (SELECT * FROM "users" NATURAL JOIN "users") AS "right"') }
  end

  context 'when the operands have different base relations' do
    let(:relation_name) { 'users_others'                           }
    let(:left)          { BaseRelation.new('users',  header, body) }
    let(:right)         { BaseRelation.new('others', header, body) }

    it_should_behave_like 'a generated SQL SELECT query'

    its(:to_s)        { should eql('SELECT "id", "name", "age" FROM "users" NATURAL JOIN "others"') }
    its(:to_subquery) { should eql('SELECT * FROM "users" NATURAL JOIN "others"') }
  end
end
