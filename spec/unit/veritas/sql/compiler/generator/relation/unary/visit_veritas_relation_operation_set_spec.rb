require 'spec_helper'

describe Generator::Relation::Unary, '#visit_veritas_relation_operation_set' do
  subject { object.visit_veritas_relation_operation_set(set) }

  let(:relation_name) { 'users'                                          }
  let(:id)            { Attribute::Integer.new(:id)                      }
  let(:name)          { Attribute::String.new(:name)                     }
  let(:age)           { Attribute::Integer.new(:age, :required => false) }
  let(:header)        { [ id, name, age ]                                }
  let(:body)          { [ [ 1, 'Dan Kubb', 35 ] ].each                   }
  let(:base_relation) { BaseRelation.new(relation_name, header, body)    }
  let(:set)           { base_relation.union(base_relation)               }
  let(:object)        { described_class.new                              }

  let(:operand) { base_relation.order }

  it { should be_kind_of(Generator::Relation::Set) }

  it_should_behave_like 'a generated SQL SELECT query'

  its(:to_s)     { should eql('(SELECT "id", "name", "age" FROM "users") UNION (SELECT "id", "name", "age" FROM "users")') }
  its(:to_inner) { should eql('(SELECT * FROM "users") UNION (SELECT * FROM "users")') }

  it { expect { subject }.to change { object.name }.from(nil).to(relation_name) }

  it { expect { subject }.to change { object.to_s }.from('').to('SELECT "id", "name", "age" FROM ((SELECT * FROM "users") UNION (SELECT * FROM "users")) AS "users"') }
end
