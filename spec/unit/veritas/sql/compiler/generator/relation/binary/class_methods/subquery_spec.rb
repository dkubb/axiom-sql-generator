require 'spec_helper'

describe SQL::Compiler::Generator::Relation::Binary, '.subquery' do
  subject { object.subquery(generator) }

  let(:id)            { Attribute::Integer.new(:id)                      }
  let(:name)          { Attribute::String.new(:name)                     }
  let(:age)           { Attribute::Integer.new(:age, :required => false) }
  let(:header)        { [ id, name, age ]                                }
  let(:body)          { [ [ 1, 'Dan Kubb', 35 ] ].each                   }
  let(:base_relation) { BaseRelation.new('users', header, body)          }
  let(:object)        { described_class                                  }

  context 'when generator is a base' do
    let(:relation)  { base_relation                                         }
    let(:generator) { SQL::Compiler::Generator::Relation::Binary::Base.new.visit(relation) }

    it_should_behave_like 'a generated SQL expression'

    its(:to_s) { should == '"users"' }
  end

  context 'when generator is a unary' do
    let(:relation)  { base_relation.project([ :id ])                 }
    let(:generator) { SQL::Compiler::Generator::Relation::Unary.new.visit(relation) }

    it_should_behave_like 'a generated SQL expression'

    its(:to_s) { should eql('(SELECT DISTINCT "id" FROM "users") AS "users"') }
  end

  context 'when generator is a binary' do
    let(:relation)  { base_relation.join(base_relation)               }
    let(:generator) { SQL::Compiler::Generator::Relation::Binary.new.visit(relation) }

    it_should_behave_like 'a generated SQL expression'

    its(:to_s) { should eql('(SELECT * FROM "users" NATURAL JOIN "users") AS "users"') }
  end
end
