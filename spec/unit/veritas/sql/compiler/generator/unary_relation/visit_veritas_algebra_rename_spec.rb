require 'spec_helper'

describe Generator::UnaryRelation, '#visit_veritas_algebra_rename' do
  subject { object.visit_veritas_algebra_rename(rename) }

  let(:klass)         { Class.new(Visitor) { include Generator::UnaryRelation } }
  let(:id)            { Attribute::Integer.new(:id)                             }
  let(:name)          { Attribute::String.new(:name)                            }
  let(:age)           { Attribute::Integer.new(:age, :required => false)        }
  let(:header)        { [ id, name, age ]                                       }
  let(:body)          { [ [ 1, 'Dan Kubb', 35 ] ].each                          }
  let(:base_relation) { BaseRelation.new('users', header, body)                 }
  let(:rename)        { base_relation.rename(:id => :user_id)                   }
  let(:object)        { klass.new                                               }

  it_should_behave_like 'a generated SQL expression'

  its(:to_s) { should eql('SELECT DISTINCT "users"."id" AS "user_id", "users"."name", "users"."age" FROM "users"') }
end
