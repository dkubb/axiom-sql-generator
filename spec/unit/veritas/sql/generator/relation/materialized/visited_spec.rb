# encoding: utf-8

require 'spec_helper'

describe SQL::Generator::Relation::Materialized, '#visited?' do
  subject { object.visited? }

  let(:object)   { described_class.new                        }
  let(:relation) { Relation.new([ [ :id, Integer ] ], [ [] ]) }

  context 'when the relation is visited' do
    before do
      object.visit_veritas_relation_materialized(relation)
    end

    it_should_behave_like 'an idempotent method'

    it { should be(true) }
  end

  context 'when the relation is not visited' do
    it_should_behave_like 'an idempotent method'

    it { should be(false) }
  end
end
