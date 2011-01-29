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

    its(:to_s) { should eql('SELECT DISTINCT "id", "name" FROM "users" ORDER BY "id", "name" OFFSET 1') }
  end

  context 'when the relation is a rename' do
    let(:relation) { base_relation.rename(:id => :user_id) }
    let(:offset)   { relation.order.drop(1)                }

    it_should_behave_like 'a generated SQL expression'

    its(:to_s) { should eql('SELECT "user_id", "name", "age" FROM (SELECT "id" AS "user_id", "name", "age" FROM "users") AS "users" ORDER BY "user_id", "name", "age" OFFSET 1') }
  end

  context 'when the relation is ordered' do
    let(:relation) { base_relation.order }
    let(:offset)   { relation.drop(1)    }

    it_should_behave_like 'a generated SQL expression'

    its(:to_s) { should eql('SELECT "id", "name", "age" FROM "users" ORDER BY "id", "name", "age" OFFSET 1') }
  end

  context 'when the relation is limited' do
    let(:relation) { base_relation.order.take(2) }
    let(:offset)   { relation.drop(1)            }

    it_should_behave_like 'a generated SQL expression'

    its(:to_s) { should eql('SELECT "id", "name", "age" FROM (SELECT * FROM "users" ORDER BY "id", "name", "age" LIMIT 2) AS "users" OFFSET 1') }
  end

  context 'when the relation is offset' do
    let(:relation) { base_relation.order.drop(1) }
    let(:offset)   { relation.drop(1)            }

    it_should_behave_like 'a generated SQL expression'

    its(:to_s) { should eql('SELECT "id", "name", "age" FROM (SELECT * FROM "users" ORDER BY "id", "name", "age" OFFSET 1) AS "users" OFFSET 1') }
  end
end
