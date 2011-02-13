require 'spec_helper'

describe Generator::BinaryRelation, '#visit_veritas_base_relation' do
  subject { object.visit_veritas_base_relation(base_relation) }

  let(:relation_name) { 'users'                                          }
  let(:id)            { Attribute::Integer.new(:id)                      }
  let(:name)          { Attribute::String.new(:name)                     }
  let(:age)           { Attribute::Integer.new(:age, :required => false) }
  let(:header)        { [ id, name, age ]                                }
  let(:body)          { [ [ 1, 'Dan Kubb', 35 ] ].each                   }
  let(:base_relation) { BaseRelation.new(relation_name, header, body)    }
  let(:object)        { described_class.new                              }

  it_should_behave_like 'a generated SQL SELECT query'

  it { should be_kind_of(Generator::UnaryRelation) }

  its(:to_s) { should eql('SELECT "id", "name", "age" FROM "users"') }
end
