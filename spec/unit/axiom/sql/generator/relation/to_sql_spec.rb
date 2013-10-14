# encoding: utf-8

require 'spec_helper'

describe SQL::Generator::Relation, '#to_sql' do
  subject { object.to_sql }

  let(:described_class) { Class.new(SQL::Generator::Relation)              }
  let(:id)              { Attribute::Integer.new(:id)                      }
  let(:name)            { Attribute::String.new(:name)                     }
  let(:age)             { Attribute::Integer.new(:age, :required => false) }
  let(:header)          { [ id, name, age ]                                }
  let(:body)            { [ [ 1, 'Dan Kubb', 35 ] ].each                   }
  let(:object)          { described_class.new                              }

  context 'when no object visited' do
    it_should_behave_like 'an idempotent method'

    it { should be_kind_of(String) }

    it { should be_frozen }

    it { should == '' }
  end

  context 'when an object is visited' do
    let(:visitable) { double('Visitable') }

    before do
      described_class.class_eval do
        def visit_rspec_mocks_mock(mock)
          mock
        end
      end
    end

    before do
      @original = object.to_sql
      object.visit(visitable)
    end

    it_should_behave_like 'an idempotent method'

    it { should be_kind_of(String) }

    it { should be_frozen }

    it { should_not equal(@original) }

    it { should eql(visitable.to_s) }
  end
end
