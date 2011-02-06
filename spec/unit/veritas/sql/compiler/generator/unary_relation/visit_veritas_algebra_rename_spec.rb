require 'spec_helper'

describe Generator::UnaryRelation, '#visit_veritas_algebra_rename' do
  subject { object.visit_veritas_algebra_rename(rename) }

  let(:id)            { Attribute::Integer.new(:id)                      }
  let(:name)          { Attribute::String.new(:name)                     }
  let(:age)           { Attribute::Integer.new(:age, :required => false) }
  let(:header)        { [ id, name, age ]                                }
  let(:body)          { [ [ 1, 'Dan Kubb', 35 ] ].each                   }
  let(:base_relation) { BaseRelation.new('users', header, body)          }
  let(:rename)        { operand.rename(:id => :user_id)                  }
  let(:object)        { described_class.new                              }

  context 'when the operand is a base relation' do
    let(:operand) { base_relation }

    it_should_behave_like 'a generated SQL expression'

    its(:to_s) { should eql('SELECT "id" AS "user_id", "name", "age" FROM "users"') }
  end

  context 'when the operand is a projection' do
    let(:operand) { base_relation.project([ :id, :name ]) }

    it_should_behave_like 'a generated SQL expression'

    its(:to_s) { should eql('SELECT DISTINCT "id" AS "user_id", "name" FROM "users"') }
  end

  context 'when the operand is a rename' do
    let(:operand) { base_relation.rename(:name => :other_name) }

    context 'when the relation is not optimized' do
      it_should_behave_like 'a generated SQL expression'

      its(:to_s) { should eql('SELECT "id" AS "user_id", "other_name", "age" FROM (SELECT "id", "name" AS "other_name", "age" FROM "users") AS "users"') }
    end

    context 'when the relation is optimized' do
      subject { object.visit_veritas_algebra_rename(rename.optimize) }

      it_should_behave_like 'a generated SQL expression'

      its(:to_s) { should eql('SELECT "id" AS "user_id", "name" AS "other_name", "age" FROM "users"') }
    end

    context 'when the operand is empty' do
      let(:operand) { base_relation.rename({}) }

      it_should_behave_like 'a generated SQL expression'

      its(:to_s) { pending { should eql('SELECT "id" AS "user_id", "name", "age" FROM "users"') } }
    end
  end

  context 'when the operand is a restriction' do
    let(:operand) { base_relation.restrict { |r| r[:id].eq(1) } }

    it_should_behave_like 'a generated SQL expression'

    its(:to_s) { should eql('SELECT "id" AS "user_id", "name", "age" FROM "users" WHERE "id" = 1') }
  end

  context 'when the operand is ordered' do
    let(:operand) { base_relation.order }

    it_should_behave_like 'a generated SQL expression'

    its(:to_s) { should eql('SELECT "id" AS "user_id", "name", "age" FROM "users" ORDER BY "id", "name", "age"') }
  end

  context 'when the operand is reversed' do
    let(:operand) { base_relation.order.reverse }

    it_should_behave_like 'a generated SQL expression'

    its(:to_s) { should eql('SELECT "id" AS "user_id", "name", "age" FROM "users" ORDER BY "id" DESC, "name" DESC, "age" DESC') }
  end

  context 'when the operand is limited' do
    let(:operand) { base_relation.order.take(1) }

    it_should_behave_like 'a generated SQL expression'

    its(:to_s) { should eql('SELECT "id" AS "user_id", "name", "age" FROM "users" ORDER BY "id", "name", "age" LIMIT 1') }
  end

  context 'when the operand is offset' do
    let(:operand) { base_relation.order.drop(1) }

    it_should_behave_like 'a generated SQL expression'

    its(:to_s) { should eql('SELECT "id" AS "user_id", "name", "age" FROM "users" ORDER BY "id", "name", "age" OFFSET 1') }
  end
end
