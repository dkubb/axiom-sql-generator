require 'spec_helper'

describe Generator::Relation::Unary, '#visit_veritas_algebra_restriction' do
  subject { object.visit_veritas_algebra_restriction(restriction) }

  let(:relation_name) { 'users'                                          }
  let(:id)            { Attribute::Integer.new(:id)                      }
  let(:name)          { Attribute::String.new(:name)                     }
  let(:age)           { Attribute::Integer.new(:age, :required => false) }
  let(:header)        { [ id, name, age ]                                }
  let(:body)          { [ [ 1, 'Dan Kubb', 35 ] ].each                   }
  let(:base_relation) { BaseRelation.new(relation_name, header, body)    }
  let(:restriction)   { operand.restrict { |r| r[:id].eq(1) }            }
  let(:object)        { described_class.new                              }

  context 'when the operand is a base relation' do
    let(:operand) { base_relation }

    it_should_behave_like 'a generated SQL SELECT query'

    its(:to_s)     { should eql('SELECT "id", "name", "age" FROM "users" WHERE "id" = 1') }
    its(:to_inner) { should eql('SELECT * FROM "users" WHERE "id" = 1') }
  end

  context 'when the operand is a projection' do
    let(:operand) { base_relation.project([ :id, :name ]) }

    it_should_behave_like 'a generated SQL SELECT query'

    its(:to_s)     { should eql('SELECT DISTINCT "id", "name" FROM "users" WHERE "id" = 1') }
    its(:to_inner) { should eql('SELECT DISTINCT "id", "name" FROM "users" WHERE "id" = 1') }
  end

  context 'when the operand is a projection then a restriction' do
    let(:operand) { base_relation.project([ :id, :name ]).restrict { |r| r[:id].ne(2) } }

    it_should_behave_like 'a generated SQL SELECT query'

    its(:to_s)     { should eql('SELECT "id", "name" FROM (SELECT DISTINCT "id", "name" FROM "users" WHERE "id" <> 2) AS "users" WHERE "id" = 1') }
    its(:to_inner) { should eql('SELECT * FROM (SELECT DISTINCT "id", "name" FROM "users" WHERE "id" <> 2) AS "users" WHERE "id" = 1') }
  end

  context 'when the operand is a projection then a restriction, followed by another restriction' do
    let(:true_proposition) { Logic::Proposition::True.instance                                                           }
    let(:operand)          { base_relation.project([ :id, :name ]).restrict(true_proposition).restrict(true_proposition) }

    it_should_behave_like 'a generated SQL SELECT query'

    its(:to_s)     { should eql('SELECT "id", "name" FROM (SELECT * FROM (SELECT DISTINCT "id", "name" FROM "users" WHERE 1 = 1) AS "users" WHERE 1 = 1) AS "users" WHERE "id" = 1') }
    its(:to_inner) { should eql('SELECT * FROM (SELECT * FROM (SELECT DISTINCT "id", "name" FROM "users" WHERE 1 = 1) AS "users" WHERE 1 = 1) AS "users" WHERE "id" = 1') }
  end

  context 'when the operand is a rename' do
    context 'when the restriction includes the renamed column' do
      let(:operand)     { base_relation.rename(:id => :user_id)      }
      let(:restriction) { operand.restrict { |r| r[:user_id].eq(1) } }

      it_should_behave_like 'a generated SQL SELECT query'

      its(:to_s)     { pending { should eql('SELECT "id" AS "user_id", "name", "age" FROM "users" WHERE "id" = 1') } }
      its(:to_inner) { pending { should eql('SELECT "id" AS "user_id", "name", "age" FROM "users" WHERE "id" = 1') } }
    end

    context 'when the restriction does not include the renamed column' do
      let(:operand)     { base_relation.rename(:name => :other_name) }
      let(:restriction) { operand.restrict { |r| r[:id].eq(1) } }

      it_should_behave_like 'a generated SQL SELECT query'

      its(:to_s)     { pending { should eql('SELECT "id", "name" AS "other_name", "age" FROM "users" WHERE "id" = 1') } }
      its(:to_inner) { pending { should eql('SELECT "id", "name" AS "other_name", "age" FROM "users" WHERE "id" = 1') } }
    end
  end

  context 'when the operand is a restriction' do
    context 'when the predicates are equivalent' do
      let(:operand) { base_relation.restrict { |r| r[:id].eq(1) } }

      it_should_behave_like 'a generated SQL SELECT query'

      its(:to_s)     { pending { should eql('SELECT "id", "name", "age" FROM "users" WHERE "id" = 1') } }
      its(:to_inner) { pending { should eql('SELECT "id", "name", "age" FROM "users" WHERE "id" = 1') } }
    end

    context 'when the predicates are different' do
      let(:operand) { base_relation.restrict { |r| r[:id].ne(2) } }

      it_should_behave_like 'a generated SQL SELECT query'

      its(:to_s)     { should eql('SELECT "id", "name", "age" FROM (SELECT * FROM "users" WHERE "id" <> 2) AS "users" WHERE "id" = 1') }
      its(:to_inner) { should eql('SELECT * FROM (SELECT * FROM "users" WHERE "id" <> 2) AS "users" WHERE "id" = 1') }
    end
  end

  context 'when the operand is ordered' do
    let(:operand) { base_relation.order }

    it_should_behave_like 'a generated SQL SELECT query'

    its(:to_s)     { should eql('SELECT "id", "name", "age" FROM "users" WHERE "id" = 1 ORDER BY "id", "name", "age"') }
    its(:to_inner) { should eql('SELECT * FROM "users" WHERE "id" = 1 ORDER BY "id", "name", "age"') }
  end

  context 'when the operand is reversed' do
    let(:operand) { base_relation.order.reverse }

    it_should_behave_like 'a generated SQL SELECT query'

    its(:to_s)     { should eql('SELECT "id", "name", "age" FROM "users" WHERE "id" = 1 ORDER BY "id" DESC, "name" DESC, "age" DESC') }
    its(:to_inner) { should eql('SELECT * FROM "users" WHERE "id" = 1 ORDER BY "id" DESC, "name" DESC, "age" DESC') }
  end

  context 'when the operand is limited' do
    let(:operand) { base_relation.order.take(1) }

    it_should_behave_like 'a generated SQL SELECT query'

    its(:to_s)     { should eql('SELECT "id", "name", "age" FROM (SELECT * FROM "users" ORDER BY "id", "name", "age" LIMIT 1) AS "users" WHERE "id" = 1') }
    its(:to_inner) { should eql('SELECT * FROM (SELECT * FROM "users" ORDER BY "id", "name", "age" LIMIT 1) AS "users" WHERE "id" = 1') }
  end

  context 'when the operand is an offset' do
    let(:operand) { base_relation.order.drop(1) }

    it_should_behave_like 'a generated SQL SELECT query'

    its(:to_s)     { should eql('SELECT "id", "name", "age" FROM (SELECT * FROM "users" ORDER BY "id", "name", "age" OFFSET 1) AS "users" WHERE "id" = 1') }
    its(:to_inner) { should eql('SELECT * FROM (SELECT * FROM "users" ORDER BY "id", "name", "age" OFFSET 1) AS "users" WHERE "id" = 1') }
  end

  context 'when the operand is a difference' do
    let(:operand) { base_relation.difference(base_relation) }

    it_should_behave_like 'a generated SQL SELECT query'

    its(:to_s)     { should eql('SELECT "id", "name", "age" FROM ((SELECT * FROM "users") EXCEPT (SELECT * FROM "users")) AS "users" WHERE "id" = 1') }
    its(:to_inner) { should eql('SELECT * FROM ((SELECT * FROM "users") EXCEPT (SELECT * FROM "users")) AS "users" WHERE "id" = 1') }
  end

  context 'when the operand is an intersection' do
    let(:operand) { base_relation.intersect(base_relation) }

    it_should_behave_like 'a generated SQL SELECT query'

    its(:to_s)     { should eql('SELECT "id", "name", "age" FROM ((SELECT * FROM "users") INTERSECT (SELECT * FROM "users")) AS "users" WHERE "id" = 1') }
    its(:to_inner) { should eql('SELECT * FROM ((SELECT * FROM "users") INTERSECT (SELECT * FROM "users")) AS "users" WHERE "id" = 1') }
  end

  context 'when the operand is a union' do
    let(:operand) { base_relation.union(base_relation) }

    it_should_behave_like 'a generated SQL SELECT query'

    its(:to_s)     { should eql('SELECT "id", "name", "age" FROM ((SELECT * FROM "users") UNION (SELECT * FROM "users")) AS "users" WHERE "id" = 1') }
    its(:to_inner) { should eql('SELECT * FROM ((SELECT * FROM "users") UNION (SELECT * FROM "users")) AS "users" WHERE "id" = 1') }
  end

  context 'when the operand is a join' do
    let(:operand) { base_relation.join(base_relation) }

    it_should_behave_like 'a generated SQL SELECT query'

    its(:to_s)     { pending { should eql('SELECT "id", "name", "age" FROM (SELECT "id", "name", "age" FROM "users" NATURAL JOIN "users") AS "users" WHERE "id" = 1') } }
    its(:to_inner) { pending { should eql('SELECT * FROM (SELECT "id", "name", "age" FROM "users" NATURAL JOIN "users") AS "users" WHERE "id" = 1') } }
  end
end
