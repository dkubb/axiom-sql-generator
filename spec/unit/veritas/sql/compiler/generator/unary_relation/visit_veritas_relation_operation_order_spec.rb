require 'spec_helper'

describe Generator::UnaryRelation, '#visit_veritas_relation_operation_order' do
  subject { object.visit_veritas_relation_operation_order(order) }

  let(:relation_name) { 'users'                                          }
  let(:id)            { Attribute::Integer.new(:id)                      }
  let(:name)          { Attribute::String.new(:name)                     }
  let(:age)           { Attribute::Integer.new(:age, :required => false) }
  let(:header)        { [ id, name, age ]                                }
  let(:body)          { [ [ 1, 'Dan Kubb', 35 ] ].each                   }
  let(:base_relation) { BaseRelation.new(relation_name, header, body)    }
  let(:order)         { operand.order                                    }
  let(:object)        { described_class.new                              }

  context 'when the operand is a base relation' do
    let(:operand) { base_relation }

    it_should_behave_like 'a generated SQL SELECT query'

    its(:to_s)     { should eql('SELECT "id", "name", "age" FROM "users" ORDER BY "id", "name", "age"') }
    its(:to_inner) { should eql('SELECT * FROM "users" ORDER BY "id", "name", "age"') }
  end

  context 'when the operand is a projection' do
    let(:operand) { base_relation.project([ :id, :name ]) }

    it_should_behave_like 'a generated SQL SELECT query'

    its(:to_s)     { should eql('SELECT DISTINCT "id", "name" FROM "users" ORDER BY "id", "name"') }
    its(:to_inner) { should eql('SELECT DISTINCT "id", "name" FROM "users" ORDER BY "id", "name"') }
  end

  context 'when the operand is a rename' do
    let(:operand) { base_relation.rename(:id => :user_id) }

    it_should_behave_like 'a generated SQL SELECT query'

    its(:to_s)     { should eql('SELECT "id" AS "user_id", "name", "age" FROM "users" ORDER BY "user_id", "name", "age"') }
    its(:to_inner) { should eql('SELECT "id" AS "user_id", "name", "age" FROM "users" ORDER BY "user_id", "name", "age"') }
  end

  context 'when the operand is a restriction' do
    let(:operand) { base_relation.restrict { |r| r[:id].eq(1) } }

    it_should_behave_like 'a generated SQL SELECT query'

    its(:to_s)     { should eql('SELECT "id", "name", "age" FROM "users" WHERE "id" = 1 ORDER BY "id", "name", "age"') }
    its(:to_inner) { should eql('SELECT * FROM "users" WHERE "id" = 1 ORDER BY "id", "name", "age"') }
  end

  context 'when the operand is ordered' do
    let(:operand) { base_relation.order }

    it_should_behave_like 'a generated SQL SELECT query'

    its(:to_s)     { should eql('SELECT "id", "name", "age" FROM "users" ORDER BY "id", "name", "age"') }
    its(:to_inner) { should eql('SELECT * FROM "users" ORDER BY "id", "name", "age"') }
  end

  context 'when the operand is reversed' do
    let(:operand) { base_relation.order.reverse }

    it_should_behave_like 'a generated SQL SELECT query'

    its(:to_s)     { should eql('SELECT "id", "name", "age" FROM "users" ORDER BY "id", "name", "age"') }
    its(:to_inner) { should eql('SELECT * FROM "users" ORDER BY "id", "name", "age"') }
  end

  context 'when the operand is limited' do
    context 'when the inner order is the same as the outer' do
      let(:operand) { base_relation.order.take(1) }

      it_should_behave_like 'a generated SQL SELECT query'

      its(:to_s)     { pending { should eql('SELECT "id", "name", "age" FROM "users" ORDER BY "id", "name", "age" LIMIT 1') } }
      its(:to_inner) { pending { should eql('SELECT * FROM "users" ORDER BY "id", "name", "age" LIMIT 1') } }
    end

    context 'when the inner order is the different from the outer, and the inner includes limit' do
      let(:operand) { base_relation.order([ id.desc, name.desc, age.desc ]).take(1) }

      it_should_behave_like 'a generated SQL SELECT query'

      its(:to_s)     { should eql('SELECT "id", "name", "age" FROM (SELECT * FROM "users" ORDER BY "id" DESC, "name" DESC, "age" DESC LIMIT 1) AS "users" ORDER BY "id", "name", "age"') }
      its(:to_inner) { should eql('SELECT * FROM (SELECT * FROM "users" ORDER BY "id" DESC, "name" DESC, "age" DESC LIMIT 1) AS "users" ORDER BY "id", "name", "age"') }
    end
  end

  context 'when the operand is an offset' do
    context 'when the inner order is the same as the outer' do
      let(:operand) { base_relation.order.drop(1) }

      it_should_behave_like 'a generated SQL SELECT query'

      its(:to_s)     { pending { should eql('SELECT "id", "name", "age" FROM "users" ORDER BY "id", "name", "age" OFFSET 1') } }
      its(:to_inner) { pending { should eql('SELECT * FROM "users" ORDER BY "id", "name", "age" OFFSET 1') } }
    end

    context 'when the inner order is the different from the outer, and the inner includes an offset' do
      let(:operand) { base_relation.order([ id.desc, name.desc, age.desc ]).drop(1) }

      it_should_behave_like 'a generated SQL SELECT query'

      its(:to_s)     { should eql('SELECT "id", "name", "age" FROM (SELECT * FROM "users" ORDER BY "id" DESC, "name" DESC, "age" DESC OFFSET 1) AS "users" ORDER BY "id", "name", "age"') }
      its(:to_inner) { should eql('SELECT * FROM (SELECT * FROM "users" ORDER BY "id" DESC, "name" DESC, "age" DESC OFFSET 1) AS "users" ORDER BY "id", "name", "age"') }
    end
  end

  context 'when the operand is a difference' do
    let(:operand) { base_relation.difference(base_relation) }

    it_should_behave_like 'a generated SQL SELECT query'

    its(:to_s)     { should eql('SELECT "id", "name", "age" FROM (SELECT * FROM "users" EXCEPT SELECT * FROM "users") AS "users" ORDER BY "id", "name", "age"') }
    its(:to_inner) { should eql('SELECT * FROM (SELECT * FROM "users" EXCEPT SELECT * FROM "users") AS "users" ORDER BY "id", "name", "age"') }
  end

  context 'when the operand is an intersection' do
    let(:operand) { base_relation.intersect(base_relation) }

    it_should_behave_like 'a generated SQL SELECT query'

    its(:to_s)     { should eql('SELECT "id", "name", "age" FROM (SELECT * FROM "users" INTERSECT SELECT * FROM "users") AS "users" ORDER BY "id", "name", "age"') }
    its(:to_inner) { should eql('SELECT * FROM (SELECT * FROM "users" INTERSECT SELECT * FROM "users") AS "users" ORDER BY "id", "name", "age"') }
  end

  context 'when the operand is a union' do
    let(:operand) { base_relation.union(base_relation) }

    it_should_behave_like 'a generated SQL SELECT query'

    its(:to_s)     { should eql('SELECT "id", "name", "age" FROM (SELECT * FROM "users" UNION SELECT * FROM "users") AS "users" ORDER BY "id", "name", "age"') }
    its(:to_inner) { should eql('SELECT * FROM (SELECT * FROM "users" UNION SELECT * FROM "users") AS "users" ORDER BY "id", "name", "age"') }
  end
end
