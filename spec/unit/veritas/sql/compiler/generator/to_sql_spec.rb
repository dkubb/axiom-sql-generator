require 'spec_helper'

describe Generator, '#to_sql' do
  subject { object.to_sql }

  let(:klass)         { Generator                                        }
  let(:id)            { Attribute::Integer.new(:id)                      }
  let(:name)          { Attribute::String.new(:name)                     }
  let(:age)           { Attribute::Integer.new(:age, :required => false) }
  let(:header)        { [ id, name, age ]                                }
  let(:body)          { [ [ 1, 'Dan Kubb', 35 ] ].each                   }
  let(:base_relation) { BaseRelation.new('users', header, body)          }
  let(:object)        { klass.new                                        }

  context 'when no object visited' do
    it_should_behave_like 'an idempotent method'

    it { should be_frozen }

    it { should == object.to_s }
  end

  context 'when an object is visited' do
    before do
      @original = object.to_sql
      object.visit(base_relation)
    end

    it_should_behave_like 'an idempotent method'

    it { should be_frozen }

    it { should_not equal(@original) }

    it { should == object.to_s }
  end
end
