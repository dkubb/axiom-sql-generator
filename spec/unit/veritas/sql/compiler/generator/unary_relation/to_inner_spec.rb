require 'spec_helper'

describe Generator::UnaryRelation, '#to_inner' do
  subject { object.to_inner }

  let(:id)            { Attribute::Integer.new(:id)                      }
  let(:name)          { Attribute::String.new(:name)                     }
  let(:age)           { Attribute::Integer.new(:age, :required => false) }
  let(:header)        { [ id, name, age ]                                }
  let(:body)          { [ [ 1, 'Dan Kubb', 35 ] ].each                   }
  let(:base_relation) { BaseRelation.new('users', header, body)          }
  let(:object)        { described_class.new                              }

  context 'when no object visited' do
    it_should_behave_like 'an idempotent method'

    it { should respond_to(:to_s) }

    it { should be_frozen }

    its(:to_s) { should == '' }
  end

  context 'when a restriction is visited' do
    before do
      object.visit(base_relation.restrict { |r| r[:id].eq(1) })
    end

    it_should_behave_like 'a generated SQL expression'

    its(:to_s) { should eql('SELECT * FROM "users" WHERE "id" = 1') }
  end

  context 'when a limit is visited' do
    before do
      object.visit(base_relation.order.take(1))
    end

    it_should_behave_like 'a generated SQL expression'

    its(:to_s) { should eql('SELECT * FROM "users" ORDER BY "id", "name", "age" LIMIT 1') }
  end

  context 'when an offset is visited' do
    before do
      object.visit(base_relation.order.drop(1))
    end

    it_should_behave_like 'a generated SQL expression'

    its(:to_s) { should eql('SELECT * FROM "users" ORDER BY "id", "name", "age" OFFSET 1') }
  end
end
