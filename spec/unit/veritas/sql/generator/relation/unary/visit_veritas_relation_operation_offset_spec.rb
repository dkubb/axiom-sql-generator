# encoding: utf-8

require 'spec_helper'

describe SQL::Generator::Relation::Unary, '#visit_veritas_relation_operation_offset' do
  subject { object.visit_veritas_relation_operation_offset(offset) }

  let(:relation_name) { 'users'                                          }
  let(:id)            { Attribute::Integer.new(:id)                      }
  let(:name)          { Attribute::String.new(:name)                     }
  let(:age)           { Attribute::Integer.new(:age, :required => false) }
  let(:header)        { [ id, name, age ]                                }
  let(:body)          { [ [ 1, 'Dan Kubb', 35 ] ].each                   }
  let(:base_relation) { Relation::Base.new(relation_name, header, body)  }
  let(:offset)        { operand.drop(1)                                  }
  let(:object)        { described_class.new                              }

  context 'when the operand is a base relation' do
    let(:operand) { base_relation.order }

    it_should_behave_like 'a generated SQL SELECT query'

    its(:to_s)        { should eql('SELECT "id", "name", "age" FROM "users" ORDER BY "id", "name", "age" OFFSET 1') }
    its(:to_subquery) { should eql('SELECT * FROM "users" ORDER BY "id", "name", "age" OFFSET 1')                   }
  end

  context 'when the operand is a projection' do
    let(:operand) { base_relation.project([ :id, :name ]).order }

    it_should_behave_like 'a generated SQL SELECT query'

    its(:to_s)        { should eql('SELECT DISTINCT "id", "name" FROM "users" ORDER BY "id", "name" OFFSET 1') }
    its(:to_subquery) { should eql('SELECT DISTINCT "id", "name" FROM "users" ORDER BY "id", "name" OFFSET 1') }
  end

  context 'when the operand is an extension' do
    let(:operand) { base_relation.extend { |r| r.add(:one, 1) }.order }

    it_should_behave_like 'a generated SQL SELECT query'

    its(:to_s)        { should eql('SELECT "id", "name", "age", 1 AS "one" FROM "users" ORDER BY "id", "name", "age", "one" OFFSET 1') }
    its(:to_subquery) { should eql('SELECT *, 1 AS "one" FROM "users" ORDER BY "id", "name", "age", "one" OFFSET 1')                   }
  end

  context 'when the operand is a rename' do
    let(:operand) { base_relation.order.rename(:id => :user_id) }

    it_should_behave_like 'a generated SQL SELECT query'

    its(:to_s)        { should eql('SELECT "id" AS "user_id", "name", "age" FROM "users" ORDER BY "id", "name", "age" OFFSET 1') }
    its(:to_subquery) { should eql('SELECT "id" AS "user_id", "name", "age" FROM "users" ORDER BY "id", "name", "age" OFFSET 1') }
  end

  context 'when the operand is a restriction' do
    let(:operand) { base_relation.order.restrict { |r| r[:id].eq(1) } }

    it_should_behave_like 'a generated SQL SELECT query'

    its(:to_s)        { should eql('SELECT "id", "name", "age" FROM "users" WHERE "id" = 1 ORDER BY "id", "name", "age" OFFSET 1') }
    its(:to_subquery) { should eql('SELECT * FROM "users" WHERE "id" = 1 ORDER BY "id", "name", "age" OFFSET 1')                   }
  end

  context 'when the operand is ordered' do
    let(:operand) { base_relation.order }

    it_should_behave_like 'a generated SQL SELECT query'

    its(:to_s)        { should eql('SELECT "id", "name", "age" FROM "users" ORDER BY "id", "name", "age" OFFSET 1') }
    its(:to_subquery) { should eql('SELECT * FROM "users" ORDER BY "id", "name", "age" OFFSET 1')                   }
  end

  context 'when the operand is reversed' do
    let(:operand) { base_relation.order.reverse }

    it_should_behave_like 'a generated SQL SELECT query'

    its(:to_s)        { should eql('SELECT "id", "name", "age" FROM "users" ORDER BY "id" DESC, "name" DESC, "age" DESC OFFSET 1') }
    its(:to_subquery) { should eql('SELECT * FROM "users" ORDER BY "id" DESC, "name" DESC, "age" DESC OFFSET 1')                   }
  end

  context 'when the operand is limited' do
    let(:operand) { base_relation.order.take(1) }

    it_should_behave_like 'a generated SQL SELECT query'

    its(:to_s)        { should eql('SELECT "id", "name", "age" FROM (SELECT * FROM "users" ORDER BY "id", "name", "age" LIMIT 1) AS "users" OFFSET 1') }
    its(:to_subquery) { should eql('SELECT * FROM (SELECT * FROM "users" ORDER BY "id", "name", "age" LIMIT 1) AS "users" OFFSET 1')                   }
  end

  context 'when the operand is an offset' do
    let(:operand) { base_relation.order.drop(1) }

    it_should_behave_like 'a generated SQL SELECT query'

    its(:to_s)        { should eql('SELECT "id", "name", "age" FROM (SELECT * FROM "users" ORDER BY "id", "name", "age" OFFSET 1) AS "users" OFFSET 1') }
    its(:to_subquery) { should eql('SELECT * FROM (SELECT * FROM "users" ORDER BY "id", "name", "age" OFFSET 1) AS "users" OFFSET 1')                   }
  end

  context 'when the operand is a difference' do
    let(:operand) { base_relation.difference(base_relation).order }

    it_should_behave_like 'a generated SQL SELECT query'

    its(:to_s)        { should eql('SELECT "id", "name", "age" FROM ((SELECT * FROM "users") EXCEPT (SELECT * FROM "users")) AS "users" ORDER BY "id", "name", "age" OFFSET 1') }
    its(:to_subquery) { should eql('SELECT * FROM ((SELECT * FROM "users") EXCEPT (SELECT * FROM "users")) AS "users" ORDER BY "id", "name", "age" OFFSET 1')                   }
  end

  context 'when the operand is an intersection' do
    let(:operand) { base_relation.intersect(base_relation).order }

    it_should_behave_like 'a generated SQL SELECT query'

    its(:to_s)        { should eql('SELECT "id", "name", "age" FROM ((SELECT * FROM "users") INTERSECT (SELECT * FROM "users")) AS "users" ORDER BY "id", "name", "age" OFFSET 1') }
    its(:to_subquery) { should eql('SELECT * FROM ((SELECT * FROM "users") INTERSECT (SELECT * FROM "users")) AS "users" ORDER BY "id", "name", "age" OFFSET 1')                   }
  end

  context 'when the operand is a union' do
    let(:operand) { base_relation.union(base_relation).order }

    it_should_behave_like 'a generated SQL SELECT query'

    its(:to_s)        { should eql('SELECT "id", "name", "age" FROM ((SELECT * FROM "users") UNION (SELECT * FROM "users")) AS "users" ORDER BY "id", "name", "age" OFFSET 1') }
    its(:to_subquery) { should eql('SELECT * FROM ((SELECT * FROM "users") UNION (SELECT * FROM "users")) AS "users" ORDER BY "id", "name", "age" OFFSET 1')                   }
  end

  context 'when the operand is a join' do
    let(:operand) { base_relation.join(base_relation).order }

    it_should_behave_like 'a generated SQL SELECT query'

    its(:to_s)        { should eql('SELECT "id", "name", "age" FROM (SELECT * FROM "users" NATURAL JOIN "users") AS "users" ORDER BY "id", "name", "age" OFFSET 1') }
    its(:to_subquery) { should eql('SELECT * FROM (SELECT * FROM "users" NATURAL JOIN "users") AS "users" ORDER BY "id", "name", "age" OFFSET 1')                   }
  end
end
