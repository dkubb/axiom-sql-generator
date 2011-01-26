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
  let(:offset)        { base_relation.order.drop(1)                             }
  let(:object)        { klass.new                                               }

  it_should_behave_like 'a generated SQL expression'

  its(:to_s) { should eql('SELECT DISTINCT "users"."id", "users"."name", "users"."age" FROM "users" ORDER BY "users"."id", "users"."name", "users"."age" OFFSET 1') }
end
