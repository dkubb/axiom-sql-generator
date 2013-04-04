# encoding: utf-8

require 'spec_helper'

describe SQL::Generator::Relation::Materialized, '#visit_axiom_relation_materialized' do
  subject { object.visit_axiom_relation_materialized(relation) }

  let(:object) { described_class.new  }
  let(:header) { [ [ :id, Integer ], [ :name, String ] ] }

  context 'with an non-empty relation' do
    let(:relation) { Relation.new(header, [ [ 1, 'John Doe' ], [ 2, 'Jane Doe' ] ]) }

    it_should_behave_like 'a generated SQL expression'

    its(:to_s)        { should eql('VALUES (1, \'John Doe\'), (2, \'Jane Doe\')')   }
    its(:to_subquery) { should eql('(VALUES (1, \'John Doe\'), (2, \'Jane Doe\'))') }
  end

  context 'with an empty relation' do
    let(:relation) { Relation.new(header, []) }

    it_should_behave_like 'a generated SQL expression'

    its(:to_s)        { should eql('SELECT 0 LIMIT 0')   }
    its(:to_subquery) { should eql('(SELECT 0 LIMIT 0)') }
  end
end
