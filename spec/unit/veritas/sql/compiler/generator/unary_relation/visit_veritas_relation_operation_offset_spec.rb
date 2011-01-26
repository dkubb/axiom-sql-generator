require 'spec_helper'

describe Generator::UnaryRelation, '#visit_veritas_relation_operation_offset' do
  subject { object.visit_veritas_relation_operation_offset(offset) }

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
    let(:offset)   { relation.order.drop(1)                }

    it_should_behave_like 'a generated SQL expression'

    its(:to_s) { should eql('SELECT DISTINCT "users"."id", "users"."name" FROM (SELECT * FROM (SELECT "users"."id", "users"."name" FROM (SELECT * FROM "users") AS "users") AS "users" ORDER BY "users"."id", "users"."name") AS "users" OFFSET 1') }
  end

  context 'when the relation is ordered' do
    let(:relation) { base_relation.order }
    let(:offset)   { relation.drop(1)    }

    it_should_behave_like 'a generated SQL expression'

    its(:to_s) { should eql('SELECT DISTINCT "users"."id", "users"."name", "users"."age" FROM (SELECT * FROM (SELECT * FROM "users") AS "users" ORDER BY "users"."id", "users"."name", "users"."age") AS "users" OFFSET 1') }
  end

  context 'when the relation is limited' do
    let(:relation) { base_relation.order.take(2) }
    let(:offset)   { relation.drop(1)            }

    it_should_behave_like 'a generated SQL expression'

    its(:to_s) { should eql('SELECT DISTINCT "users"."id", "users"."name", "users"."age" FROM (SELECT * FROM (SELECT * FROM (SELECT * FROM "users") AS "users" ORDER BY "users"."id", "users"."name", "users"."age") AS "users" LIMIT 2) AS "users" OFFSET 1') }
  end

  context 'when the relation is offset' do
    let(:relation) { base_relation.order.drop(1) }
    let(:offset)   { relation.drop(1)            }

    it_should_behave_like 'a generated SQL expression'

    its(:to_s) { should eql('SELECT DISTINCT "users"."id", "users"."name", "users"."age" FROM (SELECT * FROM (SELECT * FROM (SELECT * FROM "users") AS "users" ORDER BY "users"."id", "users"."name", "users"."age") AS "users" OFFSET 1) AS "users" OFFSET 1') }
  end
end
