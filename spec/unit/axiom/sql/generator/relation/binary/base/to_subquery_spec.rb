# encoding: utf-8

require 'spec_helper'

describe SQL::Generator::Relation::Binary::Base, '#to_subquery' do
  subject { object.to_subquery }

  let(:id)            { Attribute::Integer.new(:id)                      }
  let(:name)          { Attribute::String.new(:name)                     }
  let(:age)           { Attribute::Integer.new(:age, :required => false) }
  let(:header)        { [ id, name, age ]                                }
  let(:body)          { [ [ 1, 'Dan Kubb', 35 ] ].each                   }
  let(:base_relation) { Relation::Base.new('users', header, body)        }
  let(:object)        { described_class.new                              }

  context 'when no object visited' do
    it_should_behave_like 'an idempotent method'

    it { should respond_to(:to_s) }

    it { should be_frozen }

    its(:to_s) { should == '' }
  end

  context 'when a base relation is visited' do
    before do
      object.visit(base_relation)
    end

    it_should_behave_like 'a generated SQL expression'

    its(:to_s) { should eql('"users"') }
  end
end
