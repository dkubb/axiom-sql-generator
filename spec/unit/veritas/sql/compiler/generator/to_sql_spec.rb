require 'spec_helper'

describe Generator, '#to_sql' do
  subject { object.to_sql }

  let(:klass)  { Generator }
  let(:object) { klass.new }

  context 'when no object visited' do
    it_should_behave_like 'an idempotent method'

    it { should == '' }
  end

  context 'when a base relation is visited' do
    let(:header)        { [ [ :id, Integer ], [ :name, String ] ] }
    let(:body)          { [ [ 1, 'Dan Kubb' ] ].each              }
    let(:base_relation) { BaseRelation.new('users', header, body) }

    before do
      object.visit(base_relation)
    end

    it_should_behave_like 'an idempotent method'

    it { should == 'SELECT id, name FROM users' }
  end
end
