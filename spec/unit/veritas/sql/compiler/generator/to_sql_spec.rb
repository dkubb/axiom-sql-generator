require 'spec_helper'

describe Generator, '#to_sql' do
  subject { object.to_sql }

  let(:klass)         { Generator                                                  }
  let(:header)        { [ [ :id, Integer ], [ :name, String ], [ :age, Integer ] ] }
  let(:body)          { [ [ 1, 'Dan Kubb', 35 ] ].each                             }
  let(:base_relation) { BaseRelation.new('users', header, body)                    }
  let(:object)        { klass.new                                                  }

  before do
    @original = object.to_sql
  end

  context 'when no object visited' do
    it_should_behave_like 'an idempotent method'

    it { should_not be_frozen }

    it { should == '' }
  end

  context 'when a base relation is visited' do
    before do
      object.visit(base_relation)
    end

    it_should_behave_like 'a generated SQL query'

    it { should == 'SELECT DISTINCT id, name, age FROM users' }
  end

  context 'when a projection is visited' do
    before do
      object.visit(base_relation.project([ :id, :name ]))
    end

    it_should_behave_like 'a generated SQL query'

    it { should == 'SELECT DISTINCT id, name FROM users' }
  end

  context 'when a rename is visited' do
    before do
      object.visit(base_relation.rename(:id => :user_id))
    end

    it_should_behave_like 'a generated SQL query'

    it { should == 'SELECT DISTINCT id AS user_id, name, age FROM users' }
  end

  context 'when an order is visited' do
    before do
      object.visit(base_relation.order)
    end

    it_should_behave_like 'a generated SQL query'

    it { should == 'SELECT DISTINCT id, name, age FROM users ORDER BY id, name, age' }
  end

  context 'when a reverse is visited' do
    before do
      object.visit(base_relation.order.reverse)
    end

    it_should_behave_like 'a generated SQL query'

    it { should == 'SELECT DISTINCT id, name, age FROM users ORDER BY id DESC, name DESC, age DESC' }
  end

  context 'when a limit is visited' do
    before do
      object.visit(base_relation.order.take(1))
    end

    it_should_behave_like 'a generated SQL query'

    it { should == 'SELECT DISTINCT id, name, age FROM users ORDER BY id, name, age LIMIT 1' }
  end
end
