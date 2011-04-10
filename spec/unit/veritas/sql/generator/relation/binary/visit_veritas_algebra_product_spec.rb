# encoding: utf-8

require 'spec_helper'

describe SQL::Generator::Relation::Binary, '#visit_veritas_algebra_product' do
  subject { object.visit_veritas_algebra_product(product) }

  let(:relation_name) { 'users_other'                                                              }
  let(:id)            { Attribute::Integer.new(:id)                                                }
  let(:name)          { Attribute::String.new(:name)                                               }
  let(:age)           { Attribute::Integer.new(:age, :required => false)                           }
  let(:header)        { [ id, name, age ]                                                          }
  let(:other_header)  { [ id.rename(:other_id), name.rename(:other_name), age.rename(:other_age) ] }
  let(:body)          { [ [ 1, 'Dan Kubb', 35 ] ].each                                             }
  let(:users)         { BaseRelation.new('users', header, body)                                    }
  let(:other)         { BaseRelation.new('other', other_header, body)                              }
  let(:product)       { left.product(right)                                                        }
  let(:object)        { described_class.new                                                        }

  context 'when the operands are base relations' do
    let(:left)  { users }
    let(:right) { other }

    it_should_behave_like 'a generated SQL SELECT query'

    its(:to_s)        { should eql('SELECT "id", "name", "age", "other_id", "other_name", "other_age" FROM "users" CROSS JOIN "other"') }
    its(:to_subquery) { should eql('SELECT * FROM "users" CROSS JOIN "other"') }
  end

  context 'when the operands are a projection' do
    let(:left)  { users.project([ :id, :name ])             }
    let(:right) { other.project([ :other_id, :other_name ]) }

    it_should_behave_like 'a generated SQL SELECT query'

    its(:to_s)        { should eql('SELECT "id", "name", "other_id", "other_name" FROM (SELECT DISTINCT "id", "name" FROM "users") AS "left" CROSS JOIN (SELECT DISTINCT "other_id", "other_name" FROM "other") AS "right"') }
    its(:to_subquery) { should eql('SELECT * FROM (SELECT DISTINCT "id", "name" FROM "users") AS "left" CROSS JOIN (SELECT DISTINCT "other_id", "other_name" FROM "other") AS "right"') }
  end

  context 'when the operand is a rename' do
    let(:left)  { users.rename(:id => :user_id)             }
    let(:right) { other.rename(:other_id => :other_user_id) }

    it_should_behave_like 'a generated SQL SELECT query'

    its(:to_s)        { should eql('SELECT "user_id", "name", "age", "other_user_id", "other_name", "other_age" FROM (SELECT "id" AS "user_id", "name", "age" FROM "users") AS "left" CROSS JOIN (SELECT "other_id" AS "other_user_id", "other_name", "other_age" FROM "other") AS "right"') }
    its(:to_subquery) { should eql('SELECT * FROM (SELECT "id" AS "user_id", "name", "age" FROM "users") AS "left" CROSS JOIN (SELECT "other_id" AS "other_user_id", "other_name", "other_age" FROM "other") AS "right"') }
  end

  context 'when the operand is a restriction' do
    let(:left)  { users.restrict { |r| r[:id].eq(1) }       }
    let(:right) { other.restrict { |r| r[:other_id].eq(1) } }

    it_should_behave_like 'a generated SQL SELECT query'

    its(:to_s)        { should eql('SELECT "id", "name", "age", "other_id", "other_name", "other_age" FROM (SELECT * FROM "users" WHERE "id" = 1) AS "left" CROSS JOIN (SELECT * FROM "other" WHERE "other_id" = 1) AS "right"') }
    its(:to_subquery) { should eql('SELECT * FROM (SELECT * FROM "users" WHERE "id" = 1) AS "left" CROSS JOIN (SELECT * FROM "other" WHERE "other_id" = 1) AS "right"') }
  end

  context 'when the operand is ordered' do
    let(:left)  { users.order }
    let(:right) { other.order }

    it_should_behave_like 'a generated SQL SELECT query'

    its(:to_s)        { should eql('SELECT "id", "name", "age", "other_id", "other_name", "other_age" FROM (SELECT * FROM "users" ORDER BY "id", "name", "age") AS "left" CROSS JOIN (SELECT * FROM "other" ORDER BY "other_id", "other_name", "other_age") AS "right"') }
    its(:to_subquery) { should eql('SELECT * FROM (SELECT * FROM "users" ORDER BY "id", "name", "age") AS "left" CROSS JOIN (SELECT * FROM "other" ORDER BY "other_id", "other_name", "other_age") AS "right"') }
  end

  context 'when the operand is reversed' do
    let(:left)  { users.order.reverse }
    let(:right) { other.order.reverse }

    it_should_behave_like 'a generated SQL SELECT query'

    its(:to_s)        { should eql('SELECT "id", "name", "age", "other_id", "other_name", "other_age" FROM (SELECT * FROM "users" ORDER BY "id" DESC, "name" DESC, "age" DESC) AS "left" CROSS JOIN (SELECT * FROM "other" ORDER BY "other_id" DESC, "other_name" DESC, "other_age" DESC) AS "right"') }
    its(:to_subquery) { should eql('SELECT * FROM (SELECT * FROM "users" ORDER BY "id" DESC, "name" DESC, "age" DESC) AS "left" CROSS JOIN (SELECT * FROM "other" ORDER BY "other_id" DESC, "other_name" DESC, "other_age" DESC) AS "right"') }
  end

  context 'when the operand is limited' do
    let(:left)  { users.order.take(1) }
    let(:right) { other.order.take(1) }

    it_should_behave_like 'a generated SQL SELECT query'

    its(:to_s)        { should eql('SELECT "id", "name", "age", "other_id", "other_name", "other_age" FROM (SELECT * FROM "users" ORDER BY "id", "name", "age" LIMIT 1) AS "left" CROSS JOIN (SELECT * FROM "other" ORDER BY "other_id", "other_name", "other_age" LIMIT 1) AS "right"') }
    its(:to_subquery) { should eql('SELECT * FROM (SELECT * FROM "users" ORDER BY "id", "name", "age" LIMIT 1) AS "left" CROSS JOIN (SELECT * FROM "other" ORDER BY "other_id", "other_name", "other_age" LIMIT 1) AS "right"') }
  end

  context 'when the operand is an offset' do
    let(:left)  { users.order.drop(1) }
    let(:right) { other.order.drop(1) }

    it_should_behave_like 'a generated SQL SELECT query'

    its(:to_s)        { should eql('SELECT "id", "name", "age", "other_id", "other_name", "other_age" FROM (SELECT * FROM "users" ORDER BY "id", "name", "age" OFFSET 1) AS "left" CROSS JOIN (SELECT * FROM "other" ORDER BY "other_id", "other_name", "other_age" OFFSET 1) AS "right"') }
    its(:to_subquery) { should eql('SELECT * FROM (SELECT * FROM "users" ORDER BY "id", "name", "age" OFFSET 1) AS "left" CROSS JOIN (SELECT * FROM "other" ORDER BY "other_id", "other_name", "other_age" OFFSET 1) AS "right"') }
  end

  context 'when the operand is a difference' do
    let(:left)  { users.difference(users) }
    let(:right) { other.difference(other) }

    it_should_behave_like 'a generated SQL SELECT query'

    its(:to_s)        { should eql('SELECT "id", "name", "age", "other_id", "other_name", "other_age" FROM ((SELECT * FROM "users") EXCEPT (SELECT * FROM "users")) AS "left" CROSS JOIN ((SELECT * FROM "other") EXCEPT (SELECT * FROM "other")) AS "right"') }
    its(:to_subquery) { should eql('SELECT * FROM ((SELECT * FROM "users") EXCEPT (SELECT * FROM "users")) AS "left" CROSS JOIN ((SELECT * FROM "other") EXCEPT (SELECT * FROM "other")) AS "right"') }
  end

  context 'when the operand is a intersection' do
    let(:left)  { users.intersect(users) }
    let(:right) { other.intersect(other) }

    it_should_behave_like 'a generated SQL SELECT query'

    its(:to_s)        { should eql('SELECT "id", "name", "age", "other_id", "other_name", "other_age" FROM ((SELECT * FROM "users") INTERSECT (SELECT * FROM "users")) AS "left" CROSS JOIN ((SELECT * FROM "other") INTERSECT (SELECT * FROM "other")) AS "right"') }
    its(:to_subquery) { should eql('SELECT * FROM ((SELECT * FROM "users") INTERSECT (SELECT * FROM "users")) AS "left" CROSS JOIN ((SELECT * FROM "other") INTERSECT (SELECT * FROM "other")) AS "right"') }
  end

  context 'when the operand is a union' do
    let(:left)  { users.union(users) }
    let(:right) { other.union(other) }

    it_should_behave_like 'a generated SQL SELECT query'

    its(:to_s)        { should eql('SELECT "id", "name", "age", "other_id", "other_name", "other_age" FROM ((SELECT * FROM "users") UNION (SELECT * FROM "users")) AS "left" CROSS JOIN ((SELECT * FROM "other") UNION (SELECT * FROM "other")) AS "right"') }
    its(:to_subquery) { should eql('SELECT * FROM ((SELECT * FROM "users") UNION (SELECT * FROM "users")) AS "left" CROSS JOIN ((SELECT * FROM "other") UNION (SELECT * FROM "other")) AS "right"') }
  end

  context 'when the operand is a join' do
    let(:left)  { users.join(users) }
    let(:right) { other.join(other) }

    it_should_behave_like 'a generated SQL SELECT query'

    its(:to_s)        { should eql('SELECT "id", "name", "age", "other_id", "other_name", "other_age" FROM (SELECT * FROM "users" NATURAL JOIN "users") AS "left" CROSS JOIN (SELECT * FROM "other" NATURAL JOIN "other") AS "right"') }
    its(:to_subquery) { should eql('SELECT * FROM (SELECT * FROM "users" NATURAL JOIN "users") AS "left" CROSS JOIN (SELECT * FROM "other" NATURAL JOIN "other") AS "right"') }
  end
end
