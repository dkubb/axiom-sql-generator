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
  let(:object)        { klass.new                                               }

  context 'when the relation is a projection' do
    let(:relation) { base_relation.project([ :id, :name ]) }
    let(:limit)    { relation.order.take(1)                }

    it_should_behave_like 'a generated SQL expression'

    its(:to_s) { should eql('SELECT "users"."id", "users"."name" FROM (SELECT * FROM (SELECT DISTINCT "users"."id", "users"."name" FROM "users") AS "users" ORDER BY "users"."id", "users"."name") AS "users" LIMIT 1') }
  end

  context 'when the relation is a rename' do
    let(:relation) { base_relation.rename(:id => :user_id) }
    let(:limit)    { relation.order.take(1)                }

    it_should_behave_like 'a generated SQL expression'

    its(:to_s) { should eql('SELECT "users"."user_id", "users"."name", "users"."age" FROM (SELECT * FROM (SELECT "users"."id" AS "user_id", "users"."name", "users"."age" FROM "users") AS "users" ORDER BY "users"."user_id", "users"."name", "users"."age") AS "users" LIMIT 1') }
  end

  context 'when the relation is ordered' do
    let(:relation) { base_relation.order }
    let(:limit)    { relation.take(1)    }

    it_should_behave_like 'a generated SQL expression'

    its(:to_s) { should eql('SELECT "users"."id", "users"."name", "users"."age" FROM (SELECT * FROM "users" ORDER BY "users"."id", "users"."name", "users"."age") AS "users" LIMIT 1') }
  end

  context 'when the relation is limited' do
    let(:relation) { base_relation.order.take(2) }
    let(:limit)    { relation.take(1)            }

    it_should_behave_like 'a generated SQL expression'

    its(:to_s) { should eql('SELECT "users"."id", "users"."name", "users"."age" FROM (SELECT * FROM (SELECT * FROM "users" ORDER BY "users"."id", "users"."name", "users"."age") AS "users" LIMIT 2) AS "users" LIMIT 1') }
  end

  context 'when the relation is offset' do
    let(:relation) { base_relation.order.drop(1) }
    let(:limit)    { relation.take(1)            }

    it_should_behave_like 'a generated SQL expression'

    its(:to_s) { should eql('SELECT "users"."id", "users"."name", "users"."age" FROM (SELECT * FROM (SELECT * FROM "users" ORDER BY "users"."id", "users"."name", "users"."age") AS "users" OFFSET 1) AS "users" LIMIT 1') }
  end
end
