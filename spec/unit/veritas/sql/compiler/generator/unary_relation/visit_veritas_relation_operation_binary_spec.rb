require 'spec_helper'

describe Generator::UnaryRelation, '#visit_veritas_relation_operation_binary' do
  subject { object.visit_veritas_relation_operation_binary(binary) }

  let(:id)            { Attribute::Integer.new(:id)                      }
  let(:name)          { Attribute::String.new(:name)                     }
  let(:age)           { Attribute::Integer.new(:age, :required => false) }
  let(:header)        { [ id, name, age ]                                }
  let(:body)          { [ [ 1, 'Dan Kubb', 35 ] ].each                   }
  let(:base_relation) { BaseRelation.new('users', header, body)          }
  let(:binary)        { base_relation.union(base_relation)               }
  let(:object)        { described_class.new                              }

  let(:operand) { base_relation.order }

  it { should be_kind_of(Generator::BinaryRelation) }

  it_should_behave_like 'a generated SQL SELECT query'

  its(:to_s) { should eql('SELECT "id", "name", "age" FROM "users" UNION SELECT "id", "name", "age" FROM "users"') }

  it { expect { subject }.to change { object.name }.from(nil).to('users') }

  it { expect { subject }.to change { object.to_s }.from('').to('SELECT "id", "name", "age" FROM (SELECT * FROM "users" UNION SELECT * FROM "users") AS "users"') }
end
