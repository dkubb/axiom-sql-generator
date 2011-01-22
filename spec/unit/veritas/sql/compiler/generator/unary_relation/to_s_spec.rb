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

    it { should be_frozen }

    it { should == '' }
  end

  context 'when a base relation is visited' do
    before do
      object.visit_veritas_base_relation(base_relation)
    end

    it_should_behave_like 'a generated SQL expression'

    it { should == 'SELECT DISTINCT "users"."id", "users"."name", "users"."age" FROM "users"' }
  end

  context 'when a projection is visited' do
    before do
      object.visit_veritas_algebra_projection(base_relation.project([ :id, :name ]))
    end

    it_should_behave_like 'a generated SQL expression'

    it { should == 'SELECT DISTINCT "users"."id", "users"."name" FROM "users"' }
  end

  context 'when a rename is visited' do
    before do
      object.visit_veritas_algebra_rename(base_relation.rename(:id => :user_id))
    end

    it_should_behave_like 'a generated SQL expression'

    it { should == 'SELECT DISTINCT "users"."id" AS "user_id", "users"."name", "users"."age" FROM "users"' }
  end

  context 'when a restriction is visited' do
    before do
      object.visit_veritas_algebra_restriction(base_relation.restrict { |r| r[:id].eq(1) })
    end

    it_should_behave_like 'a generated SQL expression'

    it { should == 'SELECT DISTINCT "users"."id", "users"."name", "users"."age" FROM "users" WHERE "users"."id" = 1' }
  end

  context 'when an order is visited' do
    before do
      object.visit_veritas_relation_operation_order(base_relation.order)
    end

    it_should_behave_like 'a generated SQL expression'

    it { should == 'SELECT DISTINCT "users"."id", "users"."name", "users"."age" FROM "users" ORDER BY "users"."id", "users"."name", "users"."age"' }
  end

  context 'when a reverse is visited' do
    before do
      object.visit_veritas_relation_operation_order(base_relation.order.reverse)
    end

    it_should_behave_like 'a generated SQL expression'

    it { should == 'SELECT DISTINCT "users"."id", "users"."name", "users"."age" FROM "users" ORDER BY "users"."id" DESC, "users"."name" DESC, "users"."age" DESC' }
  end

  context 'when a limit is visited' do
    before do
      object.visit_veritas_relation_operation_limit(base_relation.order.take(1))
    end

    it_should_behave_like 'a generated SQL expression'

    it { should == 'SELECT DISTINCT "users"."id", "users"."name", "users"."age" FROM "users" ORDER BY "users"."id", "users"."name", "users"."age" LIMIT 1' }
  end

  context 'when an offset is visited' do
    before do
      object.visit_veritas_relation_operation_offset(base_relation.order.drop(1))
    end

    it_should_behave_like 'a generated SQL expression'

    it { should == 'SELECT DISTINCT "users"."id", "users"."name", "users"."age" FROM "users" ORDER BY "users"."id", "users"."name", "users"."age" OFFSET 1' }
  end
end
