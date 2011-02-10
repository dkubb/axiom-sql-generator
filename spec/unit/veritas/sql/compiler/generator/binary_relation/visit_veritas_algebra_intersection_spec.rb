require 'spec_helper'

describe Generator::BinaryRelation, '#visit_veritas_algebra_intersection' do
  subject { object.visit_veritas_algebra_intersection(intersection) }

  let(:id)            { Attribute::Integer.new(:id)                      }
  let(:name)          { Attribute::String.new(:name)                     }
  let(:age)           { Attribute::Integer.new(:age, :required => false) }
  let(:header)        { [ id, name, age ]                                }
  let(:body)          { [ [ 1, 'Dan Kubb', 35 ] ].each                   }
  let(:base_relation) { BaseRelation.new('users', header, body)          }
  let(:operand)       { base_relation                                    }
  let(:intersection)  { operand.intersect(operand)                       }
  let(:object)        { described_class.new                              }

  it_should_behave_like 'a generated SQL expression'

  its(:to_s) { should eql('SELECT "id", "name", "age" FROM "users" INTERSECT SELECT "id", "name", "age" FROM "users"') }
end
