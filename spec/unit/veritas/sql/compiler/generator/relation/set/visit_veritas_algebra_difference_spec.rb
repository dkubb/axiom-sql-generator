require 'spec_helper'

describe Generator::Relation::Set, '#visit_veritas_algebra_difference' do
  subject { object.visit_veritas_algebra_difference(difference) }

  let(:relation_name) { 'users'                                          }
  let(:id)            { Attribute::Integer.new(:id)                      }
  let(:name)          { Attribute::String.new(:name)                     }
  let(:age)           { Attribute::Integer.new(:age, :required => false) }
  let(:header)        { [ id, name, age ]                                }
  let(:body)          { [ [ 1, 'Dan Kubb', 35 ] ].each                   }
  let(:base_relation) { BaseRelation.new(relation_name, header, body)    }
  let(:left)          { operand                                          }
  let(:right)         { operand                                          }
  let(:difference)    { left.difference(right)                           }
  let(:object)        { described_class.new                              }

  context 'when the operands are base relations' do
    let(:operand) { base_relation }

    it_should_behave_like 'a generated SQL SELECT query'

    its(:to_s)        { should eql('(SELECT "id", "name", "age" FROM "users") EXCEPT (SELECT "id", "name", "age" FROM "users")') }
    its(:to_subquery) { should eql('(SELECT * FROM "users") EXCEPT (SELECT * FROM "users")') }
  end

  context 'when the operands are projections' do
    let(:operand) { base_relation.project([ :id, :name ]) }

    it_should_behave_like 'a generated SQL SELECT query'

    its(:to_s)        { should eql('(SELECT DISTINCT "id", "name" FROM "users") EXCEPT (SELECT DISTINCT "id", "name" FROM "users")') }
    its(:to_subquery) { should eql('(SELECT DISTINCT "id", "name" FROM "users") EXCEPT (SELECT DISTINCT "id", "name" FROM "users")') }
  end

  context 'when the operands are renames' do
    let(:operand) { base_relation.rename(:id => :user_id) }

    it_should_behave_like 'a generated SQL SELECT query'

    its(:to_s)        { should eql('(SELECT "id" AS "user_id", "name", "age" FROM "users") EXCEPT (SELECT "id" AS "user_id", "name", "age" FROM "users")') }
    its(:to_subquery) { should eql('(SELECT "id" AS "user_id", "name", "age" FROM "users") EXCEPT (SELECT "id" AS "user_id", "name", "age" FROM "users")') }
  end

  context 'when the operands are restrictions' do
    let(:operand) { base_relation.restrict { |r| r[:id].eq(1) } }

    it_should_behave_like 'a generated SQL SELECT query'

    its(:to_s)        { should eql('(SELECT "id", "name", "age" FROM "users" WHERE "id" = 1) EXCEPT (SELECT "id", "name", "age" FROM "users" WHERE "id" = 1)') }
    its(:to_subquery) { should eql('(SELECT * FROM "users" WHERE "id" = 1) EXCEPT (SELECT * FROM "users" WHERE "id" = 1)') }
  end

  context 'when the operand is ordered' do
    let(:operand) { base_relation.order }

    it_should_behave_like 'a generated SQL SELECT query'

    its(:to_s)        { should eql('(SELECT "id", "name", "age" FROM "users" ORDER BY "id", "name", "age") EXCEPT (SELECT "id", "name", "age" FROM "users" ORDER BY "id", "name", "age")') }
    its(:to_subquery) { should eql('(SELECT * FROM "users" ORDER BY "id", "name", "age") EXCEPT (SELECT * FROM "users" ORDER BY "id", "name", "age")') }
  end

  context 'when the operand is reversed' do
    let(:operand) { base_relation.order.reverse }

    it_should_behave_like 'a generated SQL SELECT query'

    its(:to_s)        { should eql('(SELECT "id", "name", "age" FROM "users" ORDER BY "id" DESC, "name" DESC, "age" DESC) EXCEPT (SELECT "id", "name", "age" FROM "users" ORDER BY "id" DESC, "name" DESC, "age" DESC)') }
    its(:to_subquery) { should eql('(SELECT * FROM "users" ORDER BY "id" DESC, "name" DESC, "age" DESC) EXCEPT (SELECT * FROM "users" ORDER BY "id" DESC, "name" DESC, "age" DESC)') }
  end

  context 'when the operand is limited' do
    let(:operand) { base_relation.order.take(1) }

    it_should_behave_like 'a generated SQL SELECT query'

    its(:to_s)        { should eql('(SELECT "id", "name", "age" FROM "users" ORDER BY "id", "name", "age" LIMIT 1) EXCEPT (SELECT "id", "name", "age" FROM "users" ORDER BY "id", "name", "age" LIMIT 1)') }
    its(:to_subquery) { should eql('(SELECT * FROM "users" ORDER BY "id", "name", "age" LIMIT 1) EXCEPT (SELECT * FROM "users" ORDER BY "id", "name", "age" LIMIT 1)') }
  end

  context 'when the operands are offsets' do
    let(:operand) { base_relation.order.drop(1) }

    it_should_behave_like 'a generated SQL SELECT query'

    its(:to_s)        { should eql('(SELECT "id", "name", "age" FROM "users" ORDER BY "id", "name", "age" OFFSET 1) EXCEPT (SELECT "id", "name", "age" FROM "users" ORDER BY "id", "name", "age" OFFSET 1)') }
    its(:to_subquery) { should eql('(SELECT * FROM "users" ORDER BY "id", "name", "age" OFFSET 1) EXCEPT (SELECT * FROM "users" ORDER BY "id", "name", "age" OFFSET 1)') }
  end

  context 'when the operands are differences' do
    let(:operand) { base_relation.difference(base_relation) }

    it_should_behave_like 'a generated SQL SELECT query'

    its(:to_s)        { should eql('((SELECT "id", "name", "age" FROM "users") EXCEPT (SELECT "id", "name", "age" FROM "users")) EXCEPT ((SELECT "id", "name", "age" FROM "users") EXCEPT (SELECT "id", "name", "age" FROM "users"))') }
    its(:to_subquery) { should eql('((SELECT * FROM "users") EXCEPT (SELECT * FROM "users")) EXCEPT ((SELECT * FROM "users") EXCEPT (SELECT * FROM "users"))') }
  end

  context 'when the operands are intersections' do
    let(:operand) { base_relation.intersect(base_relation) }

    it_should_behave_like 'a generated SQL SELECT query'

    its(:to_s)        { should eql('((SELECT "id", "name", "age" FROM "users") INTERSECT (SELECT "id", "name", "age" FROM "users")) EXCEPT ((SELECT "id", "name", "age" FROM "users") INTERSECT (SELECT "id", "name", "age" FROM "users"))') }
    its(:to_subquery) { should eql('((SELECT * FROM "users") INTERSECT (SELECT * FROM "users")) EXCEPT ((SELECT * FROM "users") INTERSECT (SELECT * FROM "users"))') }
  end

  context 'when the operands are unions' do
    let(:operand) { base_relation.union(base_relation) }

    it_should_behave_like 'a generated SQL SELECT query'

    its(:to_s)        { should eql('((SELECT "id", "name", "age" FROM "users") UNION (SELECT "id", "name", "age" FROM "users")) EXCEPT ((SELECT "id", "name", "age" FROM "users") UNION (SELECT "id", "name", "age" FROM "users"))') }
    its(:to_subquery) { should eql('((SELECT * FROM "users") UNION (SELECT * FROM "users")) EXCEPT ((SELECT * FROM "users") UNION (SELECT * FROM "users"))') }
  end

  context 'when the operands are joins' do
    let(:operand) { base_relation.join(base_relation) }

    it_should_behave_like 'a generated SQL SELECT query'

    its(:to_s)        { should eql('(SELECT "id", "name", "age" FROM "users" NATURAL JOIN "users") EXCEPT (SELECT "id", "name", "age" FROM "users" NATURAL JOIN "users")') }
    its(:to_subquery) { should eql('(SELECT * FROM "users" NATURAL JOIN "users") EXCEPT (SELECT * FROM "users" NATURAL JOIN "users")') }
  end

  context 'when the operands have different base relations' do
    let(:relation_name) { 'users_others'                           }
    let(:left)          { BaseRelation.new('users',  header, body) }
    let(:right)         { BaseRelation.new('others', header, body) }

    it_should_behave_like 'a generated SQL SELECT query'

    its(:to_s)        { should eql('(SELECT "id", "name", "age" FROM "users") EXCEPT (SELECT "id", "name", "age" FROM "others")') }
    its(:to_subquery) { should eql('(SELECT * FROM "users") EXCEPT (SELECT * FROM "others")') }
  end
end
