require 'spec_helper'

describe Generator::UnaryRelation, '#visit_veritas_relation_operation_limit' do
  subject { object.visit_veritas_relation_operation_limit(limit) }

  let(:klass)         { Class.new(Visitor) { include Generator::UnaryRelation } }
  let(:id)            { Attribute::Integer.new(:id)                             }
  let(:name)          { Attribute::String.new(:name)                            }
  let(:age)           { Attribute::Integer.new(:age, :required => false)        }
  let(:header)        { [ id, name, age ]                                       }
  let(:body)          { [ [ 1, 'Dan Kubb', 35 ] ].each                          }
  let(:base_relation) { BaseRelation.new('users', header, body)                 }
  let(:limit)         { operand.take(1)                                         }
  let(:object)        { klass.new                                               }

  context 'when the operand is a base relation' do
    let(:operand) { base_relation.order }

    it_should_behave_like 'a generated SQL expression'

    its(:to_s) { should eql('SELECT "id", "name", "age" FROM "users" ORDER BY "id", "name", "age" LIMIT 1') }
  end

  context 'when the operand is a projection' do
    let(:operand) { base_relation.project([ :id, :name ]).order }

    it_should_behave_like 'a generated SQL expression'

    its(:to_s) { should eql('SELECT DISTINCT "id", "name" FROM "users" ORDER BY "id", "name" LIMIT 1') }
  end

  context 'when the operand is a rename' do
    let(:operand) { base_relation.order.rename(:id => :user_id) }

    it_should_behave_like 'a generated SQL expression'

    its(:to_s) { should eql('SELECT "id" AS "user_id", "name", "age" FROM "users" ORDER BY "id", "name", "age" LIMIT 1') }
  end

  context 'when the operand is a restriction' do
    let(:operand) { base_relation.order.restrict { |r| r[:id].eq(1) } }

    it_should_behave_like 'a generated SQL expression'

    its(:to_s) { should eql('SELECT "id", "name", "age" FROM "users" WHERE "id" = 1 ORDER BY "id", "name", "age" LIMIT 1') }
  end

  context 'when the operand is ordered' do
    let(:operand) { base_relation.order }

    it_should_behave_like 'a generated SQL expression'

    its(:to_s) { should eql('SELECT "id", "name", "age" FROM "users" ORDER BY "id", "name", "age" LIMIT 1') }
  end

  context 'when the operand is reversed' do
    let(:operand) { base_relation.order.reverse }

    it_should_behave_like 'a generated SQL expression'

    its(:to_s) { should eql('SELECT "id", "name", "age" FROM "users" ORDER BY "id" DESC, "name" DESC, "age" DESC LIMIT 1') }
  end

  context 'when the operand is limited' do
    let(:operand) { base_relation.order.take(1) }

    context 'when the relation is not optimized' do
      it_should_behave_like 'a generated SQL expression'

      its(:to_s) { should eql('SELECT "id", "name", "age" FROM (SELECT * FROM "users" ORDER BY "id", "name", "age" LIMIT 1) AS "users" LIMIT 1') }
    end

    context 'when the relation is optimized' do
      subject { object.visit_veritas_relation_operation_limit(limit.optimize) }

      it_should_behave_like 'a generated SQL expression'

      its(:to_s) { should eql('SELECT "id", "name", "age" FROM "users" ORDER BY "id", "name", "age" LIMIT 1') }
    end
  end

  context 'when the operand is offset' do
    let(:operand) { base_relation.order.drop(1) }

    it_should_behave_like 'a generated SQL expression'

    its(:to_s) { should eql('SELECT "id", "name", "age" FROM "users" ORDER BY "id", "name", "age" LIMIT 1 OFFSET 1') }
  end
end
