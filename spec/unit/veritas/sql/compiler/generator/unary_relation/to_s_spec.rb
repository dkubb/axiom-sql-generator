require 'spec_helper'

describe Generator::UnaryRelation, '#to_s' do
  subject { object.to_s }

  let(:klass)         { Class.new(Visitor) { include Generator::UnaryRelation } }
  let(:id)            { Attribute::Integer.new(:id)                             }
  let(:name)          { Attribute::String.new(:name)                            }
  let(:age)           { Attribute::Integer.new(:age, :required => false)        }
  let(:header)        { [ id, name, age ]                                       }
  let(:body)          { [ [ 1, 'Dan Kubb', 35 ] ].each                          }
  let(:base_relation) { BaseRelation.new('users', header, body)                 }
  let(:object)        { klass.new                                               }

  context 'when no object visited' do
    it_should_behave_like 'an idempotent method'

    it { should respond_to(:to_s) }

    it { should be_frozen }

    its(:to_s) { should == '' }
  end

  context 'when a restriction is visited' do
    before do
      object.visit_veritas_algebra_restriction(base_relation.restrict { |r| r[:id].eq(1) })
    end

    it_should_behave_like 'a generated SQL expression'

    its(:to_s) { should eql('SELECT DISTINCT "users"."id", "users"."name", "users"."age" FROM (SELECT DISTINCT "users"."id", "users"."name", "users"."age" FROM "users") AS "users" WHERE "users"."id" = 1') }
  end

  context 'when a limit is visited' do
    before do
      object.visit_veritas_relation_operation_limit(base_relation.order.take(1))
    end

    it_should_behave_like 'a generated SQL expression'

    its(:to_s) { should eql('SELECT DISTINCT "users"."id", "users"."name", "users"."age" FROM (SELECT DISTINCT "users"."id", "users"."name", "users"."age" FROM (SELECT DISTINCT "users"."id", "users"."name", "users"."age" FROM "users") AS "users" ORDER BY "users"."id", "users"."name", "users"."age") AS "users" LIMIT 1') }
  end

  context 'when an offset is visited' do
    before do
      object.visit_veritas_relation_operation_offset(base_relation.order.drop(1))
    end

    it_should_behave_like 'a generated SQL expression'

    its(:to_s) { should eql('SELECT DISTINCT "users"."id", "users"."name", "users"."age" FROM (SELECT DISTINCT "users"."id", "users"."name", "users"."age" FROM (SELECT DISTINCT "users"."id", "users"."name", "users"."age" FROM "users") AS "users" ORDER BY "users"."id", "users"."name", "users"."age") AS "users" OFFSET 1') }
  end
end
