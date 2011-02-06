require 'spec_helper'

describe Generator::UnaryRelation, '#visited?' do
  subject { object.visited? }

  let(:id)            { Attribute::Integer.new(:id)                      }
  let(:name)          { Attribute::String.new(:name)                     }
  let(:age)           { Attribute::Integer.new(:age, :required => false) }
  let(:header)        { [ id, name, age ]                                }
  let(:body)          { [ [ 1, 'Dan Kubb', 35 ] ].each                   }
  let(:base_relation) { BaseRelation.new('users', header, body)          }
  let(:object)        { described_class.new                              }

  context 'when an object have been visited' do
    before do
      object.visit_veritas_base_relation(base_relation)
    end

    it { should be(true) }
  end

  context 'when an object has not been visited' do
    it { should be(false) }
  end
end
