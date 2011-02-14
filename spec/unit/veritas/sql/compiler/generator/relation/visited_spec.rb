require 'spec_helper'

describe Generator::Relation, '#visited?' do
  subject { object.visited? }

  let(:id)            { Attribute::Integer.new(:id)                      }
  let(:name)          { Attribute::String.new(:name)                     }
  let(:age)           { Attribute::Integer.new(:age, :required => false) }
  let(:header)        { [ id, name, age ]                                }
  let(:body)          { [ [ 1, 'Dan Kubb', 35 ] ].each                   }
  let(:base_relation) { BaseRelation.new('users', header, body)          }
  let(:object)        { described_class.new                              }

  context 'when name is nil' do
    it_should_behave_like 'an idempotent method'

    it { should be(false) }
  end

  context 'when name is set' do
    let(:name) { 'test' }

    before do
      # subclasses set @name, but nothing in this class
      # does does so simulate it being set
      object.instance_variable_set(:@name, name)
    end

    it_should_behave_like 'an idempotent method'

    it { should be(true) }
  end
end
