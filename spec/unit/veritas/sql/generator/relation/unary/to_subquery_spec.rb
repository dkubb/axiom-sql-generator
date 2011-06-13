# encoding: utf-8

require 'spec_helper'

describe SQL::Generator::Relation::Unary, '#to_subquery' do
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

  context 'when a projection is visited' do
    before do
      object.visit(base_relation.project([ :id, :name ]))
    end

    it_should_behave_like 'a generated SQL expression'

    its(:to_s) { should eql('(SELECT DISTINCT "id", "name" FROM "users")') }
  end

  context 'when a rename is visited' do
    before do
      object.visit(base_relation.rename(:id => :user_id))
    end

    it_should_behave_like 'a generated SQL expression'

    its(:to_s) { should eql('(SELECT "id" AS "user_id", "name", "age" FROM "users")') }
  end

  context 'when a restriction is visited' do
    before do
      object.visit(base_relation.restrict { |r| r[:id].eq(1) })
    end

    it_should_behave_like 'a generated SQL expression'

    its(:to_s) { should eql('(SELECT * FROM "users" WHERE "id" = 1)') }
  end

  context 'when a limit is visited' do
    before do
      object.visit(base_relation.sort_by { |r| [ r[:id], r[:name], r[:age] ] }.take(1))
    end

    it_should_behave_like 'a generated SQL expression'

    its(:to_s) { should eql('(SELECT * FROM "users" ORDER BY "id", "name", "age" LIMIT 1)') }
  end

  context 'when an offset is visited' do
    before do
      object.visit(base_relation.sort_by { |r| [ r[:id], r[:name], r[:age] ] }.drop(1))
    end

    it_should_behave_like 'a generated SQL expression'

    its(:to_s) { should eql('(SELECT * FROM "users" ORDER BY "id", "name", "age" OFFSET 1)') }
  end
end
