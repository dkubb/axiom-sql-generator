# encoding: utf-8

require 'spec_helper'

describe SQL::Generator::Relation, '#to_subquery' do
  subject { object.to_subquery }

  let(:described_class) { Class.new(SQL::Generator::Relation)              }
  let(:id)              { Attribute::Integer.new(:id)                      }
  let(:name)            { Attribute::String.new(:name)                     }
  let(:age)             { Attribute::Integer.new(:age, :required => false) }
  let(:header)          { [ id, name, age ]                                }
  let(:body)            { [ [ 1, 'Dan Kubb', 35 ] ].each                   }
  let(:base_relation)   { Relation::Base.new('users', header, body)        }
  let(:object)          { described_class.new                              }

  context 'when no object visited' do
    it_should_behave_like 'an idempotent method'

    it { should respond_to(:to_s) }

    it { should be_frozen }

    its(:to_s) { should == '' }
  end

  context 'when an object is visited' do
    let(:visitable) { double('Visitable') }

    before do
      described_class.class_eval do
        def visit_rspec_mocks_mock(mock)
          @name  = mock.instance_variable_get(:@name)
          @scope = Set.new
        end

        def generate_sql(columns)
          "SELECT #{columns} FROM #{@name}"
        end
      end

      object.visit(visitable)
    end

    it_should_behave_like 'a generated SQL expression'

    its(:to_s) { should eql('(SELECT * FROM Visitable)') }
  end
end
