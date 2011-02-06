require 'spec_helper'

describe Generator::UnaryRelation, '#visit_veritas_relation_operation_reverse' do
  subject { object.visit_veritas_relation_operation_reverse(order) }

  let(:described_class) { Class.new(Visitor) { include Generator::UnaryRelation } }
  let(:id)              { Attribute::Integer.new(:id)                             }
  let(:name)            { Attribute::String.new(:name)                            }
  let(:age)             { Attribute::Integer.new(:age, :required => false)        }
  let(:header)          { [ id, name, age ]                                       }
  let(:body)            { [ [ 1, 'Dan Kubb', 35 ] ].each                          }
  let(:base_relation)   { BaseRelation.new('users', header, body)                 }
  let(:order)           { operand.reverse                                         }
  let(:object)          { described_class.new                                     }

  context 'when the operand is a base relation' do
    let(:operand) { base_relation.order }

    it_should_behave_like 'a generated SQL expression'

    its(:to_s) { should eql('SELECT "id", "name", "age" FROM "users" ORDER BY "id" DESC, "name" DESC, "age" DESC') }
  end

  context 'when the operand is a projection' do
    let(:operand) { base_relation.project([ :id, :name ]).order }

    it_should_behave_like 'a generated SQL expression'

    its(:to_s) { should eql('SELECT DISTINCT "id", "name" FROM "users" ORDER BY "id" DESC, "name" DESC') }
  end

  context 'when the operand is a rename' do
    let(:operand) { base_relation.order.rename(:id => :user_id) }

    it_should_behave_like 'a generated SQL expression'

    its(:to_s) { should eql('SELECT "id" AS "user_id", "name", "age" FROM "users" ORDER BY "user_id" DESC, "name" DESC, "age" DESC') }
  end

  context 'when the operand is a restriction' do
    let(:operand) { base_relation.order.restrict { |r| r[:id].eq(1) } }

    it_should_behave_like 'a generated SQL expression'

    its(:to_s) { should eql('SELECT "id", "name", "age" FROM "users" WHERE "id" = 1 ORDER BY "id" DESC, "name" DESC, "age" DESC') }
  end

  context 'when the operand is ordered' do
    let(:operand) { base_relation.order }

    it_should_behave_like 'a generated SQL expression'

    its(:to_s) { should eql('SELECT "id", "name", "age" FROM "users" ORDER BY "id" DESC, "name" DESC, "age" DESC') }
  end

  context 'when the operand is reversed' do
    let(:operand) { base_relation.order.reverse }

    it_should_behave_like 'a generated SQL expression'

    its(:to_s) { should eql('SELECT "id", "name", "age" FROM "users" ORDER BY "id", "name", "age"') }
  end

  context 'when the operand is limited' do
    let(:operand) { base_relation.order.take(1) }

    it_should_behave_like 'a generated SQL expression'

    its(:to_s) { should eql('SELECT "id", "name", "age" FROM (SELECT * FROM "users" ORDER BY "id", "name", "age" LIMIT 1) AS "users" ORDER BY "id" DESC, "name" DESC, "age" DESC') }
  end

  context 'when the operand is offset' do
    let(:operand) { base_relation.order.drop(1) }

    it_should_behave_like 'a generated SQL expression'

    its(:to_s) { should eql('SELECT "id", "name", "age" FROM (SELECT * FROM "users" ORDER BY "id", "name", "age" OFFSET 1) AS "users" ORDER BY "id" DESC, "name" DESC, "age" DESC') }
  end
end
