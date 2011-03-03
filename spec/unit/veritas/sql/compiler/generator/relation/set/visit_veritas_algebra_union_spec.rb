require 'spec_helper'

describe Generator::Relation::Set, '#visit_veritas_algebra_union' do
  subject { object.visit_veritas_algebra_union(union) }

  let(:relation_name) { 'users'                                          }
  let(:id)            { Attribute::Integer.new(:id)                      }
  let(:name)          { Attribute::String.new(:name)                     }
  let(:age)           { Attribute::Integer.new(:age, :required => false) }
  let(:header)        { [ id, name, age ]                                }
  let(:body)          { [ [ 1, 'Dan Kubb', 35 ] ].each                   }
  let(:base_relation) { BaseRelation.new(relation_name, header, body)    }
  let(:left)          { operand                                          }
  let(:right)         { operand                                          }
  let(:union)         { left.union(right)                                }
  let(:object)        { described_class.new                              }

  context 'when the operand is a base relation' do
    let(:operand) { base_relation }

    it_should_behave_like 'a generated SQL SELECT query'

    its(:to_s)     { should eql('(SELECT "id", "name", "age" FROM "users") UNION (SELECT "id", "name", "age" FROM "users")') }
    its(:to_inner) { should eql('(SELECT * FROM "users") UNION (SELECT * FROM "users")') }
  end

  context 'when the operand is a projection' do
    let(:operand) { base_relation.project([ :id, :name ]) }

    it_should_behave_like 'a generated SQL SELECT query'

    its(:to_s)     { should eql('(SELECT DISTINCT "id", "name" FROM "users") UNION (SELECT DISTINCT "id", "name" FROM "users")') }
    its(:to_inner) { should eql('(SELECT DISTINCT "id", "name" FROM "users") UNION (SELECT DISTINCT "id", "name" FROM "users")') }
  end

  context 'when the operand is a rename' do
    let(:operand) { base_relation.rename(:id => :user_id) }

    it_should_behave_like 'a generated SQL SELECT query'

    its(:to_s)     { should eql('(SELECT "id" AS "user_id", "name", "age" FROM "users") UNION (SELECT "id" AS "user_id", "name", "age" FROM "users")') }
    its(:to_inner) { should eql('(SELECT "id" AS "user_id", "name", "age" FROM "users") UNION (SELECT "id" AS "user_id", "name", "age" FROM "users")') }
  end

  context 'when the operand is a restriction' do
    let(:operand) { base_relation.restrict { |r| r[:id].eq(1) } }

    it_should_behave_like 'a generated SQL SELECT query'

    its(:to_s)     { should eql('(SELECT "id", "name", "age" FROM "users" WHERE "id" = 1) UNION (SELECT "id", "name", "age" FROM "users" WHERE "id" = 1)') }
    its(:to_inner) { should eql('(SELECT * FROM "users" WHERE "id" = 1) UNION (SELECT * FROM "users" WHERE "id" = 1)') }
  end

  context 'when the operand is ordered' do
    let(:operand) { base_relation.order }

    it_should_behave_like 'a generated SQL SELECT query'

    its(:to_s)     { should eql('(SELECT "id", "name", "age" FROM "users" ORDER BY "id", "name", "age") UNION (SELECT "id", "name", "age" FROM "users" ORDER BY "id", "name", "age")') }
    its(:to_inner) { should eql('(SELECT * FROM "users" ORDER BY "id", "name", "age") UNION (SELECT * FROM "users" ORDER BY "id", "name", "age")') }
  end

  context 'when the operand is reversed' do
    let(:operand) { base_relation.order.reverse }

    it_should_behave_like 'a generated SQL SELECT query'

    its(:to_s)     { should eql('(SELECT "id", "name", "age" FROM "users" ORDER BY "id" DESC, "name" DESC, "age" DESC) UNION (SELECT "id", "name", "age" FROM "users" ORDER BY "id" DESC, "name" DESC, "age" DESC)') }
    its(:to_inner) { should eql('(SELECT * FROM "users" ORDER BY "id" DESC, "name" DESC, "age" DESC) UNION (SELECT * FROM "users" ORDER BY "id" DESC, "name" DESC, "age" DESC)') }
  end

  context 'when the operand is limited' do
    let(:operand) { base_relation.order.take(1) }

    it_should_behave_like 'a generated SQL SELECT query'

    its(:to_s)     { should eql('(SELECT "id", "name", "age" FROM "users" ORDER BY "id", "name", "age" LIMIT 1) UNION (SELECT "id", "name", "age" FROM "users" ORDER BY "id", "name", "age" LIMIT 1)') }
    its(:to_inner) { should eql('(SELECT * FROM "users" ORDER BY "id", "name", "age" LIMIT 1) UNION (SELECT * FROM "users" ORDER BY "id", "name", "age" LIMIT 1)') }
  end

  context 'when the operand is an offset' do
    let(:operand) { base_relation.order.drop(1) }

    it_should_behave_like 'a generated SQL SELECT query'

    its(:to_s)     { should eql('(SELECT "id", "name", "age" FROM "users" ORDER BY "id", "name", "age" OFFSET 1) UNION (SELECT "id", "name", "age" FROM "users" ORDER BY "id", "name", "age" OFFSET 1)') }
    its(:to_inner) { should eql('(SELECT * FROM "users" ORDER BY "id", "name", "age" OFFSET 1) UNION (SELECT * FROM "users" ORDER BY "id", "name", "age" OFFSET 1)') }
  end

  context 'when the operand is a difference' do
    let(:operand) { base_relation.difference(base_relation) }

    it_should_behave_like 'a generated SQL SELECT query'

    its(:to_s)     { should eql('((SELECT "id", "name", "age" FROM "users") EXCEPT (SELECT "id", "name", "age" FROM "users")) UNION ((SELECT "id", "name", "age" FROM "users") EXCEPT (SELECT "id", "name", "age" FROM "users"))') }
    its(:to_inner) { should eql('((SELECT * FROM "users") EXCEPT (SELECT * FROM "users")) UNION ((SELECT * FROM "users") EXCEPT (SELECT * FROM "users"))') }
  end

  context 'when the operand is an intersection' do
    let(:operand) { base_relation.intersect(base_relation) }

    it_should_behave_like 'a generated SQL SELECT query'

    its(:to_s)     { should eql('((SELECT "id", "name", "age" FROM "users") INTERSECT (SELECT "id", "name", "age" FROM "users")) UNION ((SELECT "id", "name", "age" FROM "users") INTERSECT (SELECT "id", "name", "age" FROM "users"))') }
    its(:to_inner) { should eql('((SELECT * FROM "users") INTERSECT (SELECT * FROM "users")) UNION ((SELECT * FROM "users") INTERSECT (SELECT * FROM "users"))') }
  end

  context 'when the operand is a union' do
    let(:operand) { base_relation.union(base_relation) }

    it_should_behave_like 'a generated SQL SELECT query'

    its(:to_s)     { should eql('((SELECT "id", "name", "age" FROM "users") UNION (SELECT "id", "name", "age" FROM "users")) UNION ((SELECT "id", "name", "age" FROM "users") UNION (SELECT "id", "name", "age" FROM "users"))') }
    its(:to_inner) { should eql('((SELECT * FROM "users") UNION (SELECT * FROM "users")) UNION ((SELECT * FROM "users") UNION (SELECT * FROM "users"))') }
  end

  context 'when the operand is a join' do
    let(:operand) { base_relation.join(base_relation) }

    it_should_behave_like 'a generated SQL SELECT query'

    its(:to_s)     { should eql('(SELECT "id", "name", "age" FROM "users" NATURAL JOIN "users") UNION (SELECT "id", "name", "age" FROM "users" NATURAL JOIN "users")') }
    its(:to_inner) { should eql('(SELECT * FROM "users" NATURAL JOIN "users") UNION (SELECT * FROM "users" NATURAL JOIN "users")') }
  end

  context 'when the operands have different base relations' do
    let(:relation_name) { 'users_others'                           }
    let(:left)          { BaseRelation.new('users',  header, body) }
    let(:right)         { BaseRelation.new('others', header, body) }

    it_should_behave_like 'a generated SQL SELECT query'

    its(:to_s)     { should eql('(SELECT "id", "name", "age" FROM "users") UNION (SELECT "id", "name", "age" FROM "others")') }
    its(:to_inner) { should eql('(SELECT * FROM "users") UNION (SELECT * FROM "others")') }
  end
end
