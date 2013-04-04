# encoding: utf-8

require 'spec_helper'

describe SQL::Generator::Relation::Unary, '#visit_axiom_relation_base' do
  subject { object.visit_axiom_relation_base(base_relation) }

  let(:relation_name) { 'users'                                          }
  let(:id)            { Attribute::Integer.new(:id)                      }
  let(:name)          { Attribute::String.new(:name)                     }
  let(:age)           { Attribute::Integer.new(:age, :required => false) }
  let(:header)        { [ id, name, age ]                                }
  let(:body)          { [ [ 1, 'Dan Kubb', 35 ] ].each                   }
  let(:base_relation) { Relation::Base.new(relation_name, header, body)  }
  let(:object)        { described_class.new                              }

  it_should_behave_like 'a generated SQL SELECT query'

  its(:to_s)        { should eql('SELECT "id", "name", "age" FROM "users"') }
  its(:to_subquery) { should eql('(SELECT * FROM "users")')                 }
end
