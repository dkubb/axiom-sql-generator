require 'spec_helper'

describe Generator::BinaryRelation, '#visit_veritas_relation_operation_unary' do
  subject { object.visit_veritas_relation_operation_unary(base_relation) }

  let(:id)            { Attribute::Integer.new(:id)                      }
  let(:name)          { Attribute::String.new(:name)                     }
  let(:age)           { Attribute::Integer.new(:age, :required => false) }
  let(:header)        { [ id, name, age ]                                }
  let(:body)          { [ [ 1, 'Dan Kubb', 35 ] ].each                   }
  let(:base_relation) { BaseRelation.new('users', header, body)          }
  let(:unary)         { base_relation.rename({})                         }
  let(:object)        { described_class.new                              }

  it_should_behave_like 'a generated SQL expression'

  it { should be_kind_of(Generator::UnaryRelation) }

  its(:to_s) { should eql('SELECT "id", "name", "age" FROM "users"') }
end
