require 'spec_helper'

describe Generator::UnaryRelation, '#visit_veritas_algebra_projection' do
  subject { object.visit_veritas_algebra_projection(projection) }

  let(:klass)         { Class.new(Visitor) { include Generator::UnaryRelation } }
  let(:id)            { Attribute::Integer.new(:id)                             }
  let(:name)          { Attribute::String.new(:name)                            }
  let(:age)           { Attribute::Integer.new(:age, :required => false)        }
  let(:header)        { [ id, name, age ]                                       }
  let(:body)          { [ [ 1, 'Dan Kubb', 35 ] ].each                          }
  let(:base_relation) { BaseRelation.new('users', header, body)                 }
  let(:projection)    { operand.project([ :id, :name ])                         }
  let(:object)        { klass.new                                               }

  context 'when the operand is a base relation' do
    let(:operand) { base_relation }

    it_should_behave_like 'a generated SQL expression'

    its(:to_s) { should eql('SELECT DISTINCT "id", "name" FROM "users"') }
  end

  context 'when the operand is a projection' do
    let(:operand) { base_relation.project([ :id, :name ]) }

    it_should_behave_like 'a generated SQL expression'

    its(:to_s) { should eql('SELECT DISTINCT "id", "name" FROM (SELECT DISTINCT "id", "name" FROM "users") AS "users"') }
  end

  context 'when the operand is a rename' do
    let(:operand)    { base_relation.rename(:id => :user_id) }
    let(:projection) { operand.project([ :user_id, :name ])  }

    it_should_behave_like 'a generated SQL expression'

    its(:to_s) { pending { should eql('SELECT DISTINCT "id" AS "user_id", "name" FROM "users"') } }
  end

  context 'when the operand is a restriction' do
    let(:operand) { base_relation.restrict { |r| r[:id].eq(1) } }

    it_should_behave_like 'a generated SQL expression'

    its(:to_s) { pending { should eql('SELECT DISTINCT "id", "name" FROM "users" WHERE "id" = 1') } }
  end

  context 'when the operand is ordered' do
    let(:operand) { base_relation.order }

    it_should_behave_like 'a generated SQL expression'

    its(:to_s) { should eql('SELECT DISTINCT "id", "name" FROM (SELECT * FROM "users" ORDER BY "id", "name", "age") AS "users"') }
  end

  context 'when the operand is limited' do
    let(:operand) { base_relation.order.take(1) }

    it_should_behave_like 'a generated SQL expression'

    its(:to_s) { should eql('SELECT DISTINCT "id", "name" FROM (SELECT * FROM "users" ORDER BY "id", "name", "age" LIMIT 1) AS "users"') }
  end

  context 'when the operand is offset' do
    let(:operand) { base_relation.order.drop(1) }

    it_should_behave_like 'a generated SQL expression'

    its(:to_s) { should eql('SELECT DISTINCT "id", "name" FROM (SELECT * FROM "users" ORDER BY "id", "name", "age" OFFSET 1) AS "users"') }
  end
end
