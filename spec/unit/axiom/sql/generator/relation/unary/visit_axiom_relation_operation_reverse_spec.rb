# encoding: utf-8

require 'spec_helper'

describe SQL::Generator::Relation::Unary, '#visit_axiom_relation_operation_reverse' do
  subject { object.visit_axiom_relation_operation_reverse(sorted) }

  let(:relation_name) { 'users'                                         }
  let(:id)            { Attribute::Integer.new(:id)                     }
  let(:name)          { Attribute::String.new(:name)                    }
  let(:age)           { Attribute::Integer.new(:age, required: false)   }
  let(:header)        { [id, name, age]                                 }
  let(:body)          { [[1, 'Dan Kubb', 35]].each                      }
  let(:base_relation) { Relation::Base.new(relation_name, header, body) }
  let(:sorted)        { operand.reverse                                 }
  let(:object)        { described_class.new                             }

  context 'when the operand is a base relation' do
    let(:operand) { base_relation.sort_by { |r| [r.id, r.name, r.age] } }

    it_should_behave_like 'a generated SQL SELECT query'

    its(:to_s)        { should eql('SELECT "id", "name", "age" FROM "users" ORDER BY "id" DESC, "name" DESC, "age" DESC') }
    its(:to_subquery) { should eql('(SELECT * FROM "users" ORDER BY "id" DESC, "name" DESC, "age" DESC)')                 }
  end

  context 'when the operand is a projection' do
    let(:operand) { base_relation.project([:id, :name]).sort_by { |r| [r.id, r.name] } }

    it_should_behave_like 'a generated SQL SELECT query'

    its(:to_s)        { should eql('SELECT DISTINCT "id", "name" FROM "users" ORDER BY "id" DESC, "name" DESC')   }
    its(:to_subquery) { should eql('(SELECT DISTINCT "id", "name" FROM "users" ORDER BY "id" DESC, "name" DESC)') }
  end

  context 'when the operand is an extension' do
    let(:operand) { base_relation.extend { |r| r.add(:one, 1) }.sort_by { |r| [r.id, r.name, r.age, r.one] } }

    it_should_behave_like 'a generated SQL SELECT query'

    its(:to_s)        { should eql('SELECT "id", "name", "age", 1 AS "one" FROM "users" ORDER BY "id" DESC, "name" DESC, "age" DESC, "one" DESC') }
    its(:to_subquery) { should eql('(SELECT *, 1 AS "one" FROM "users" ORDER BY "id" DESC, "name" DESC, "age" DESC, "one" DESC)')                 }
  end

  context 'when the operand is a rename' do
    let(:operand) { base_relation.sort_by { |r| [r.id, r.name, r.age] }.rename(id: :user_id) }

    it_should_behave_like 'a generated SQL SELECT query'

    its(:to_s)        { should eql('SELECT "id" AS "user_id", "name", "age" FROM "users" ORDER BY "user_id" DESC, "name" DESC, "age" DESC')   }
    its(:to_subquery) { should eql('(SELECT "id" AS "user_id", "name", "age" FROM "users" ORDER BY "user_id" DESC, "name" DESC, "age" DESC)') }
  end

  context 'when the operand is a restriction' do
    let(:operand) { base_relation.restrict { |r| r.id.eq(1) }.sort_by { |r| [r.id, r.name, r.age] } }

    it_should_behave_like 'a generated SQL SELECT query'

    its(:to_s)        { should eql('SELECT "id", "name", "age" FROM "users" WHERE "id" = 1 ORDER BY "id" DESC, "name" DESC, "age" DESC') }
    its(:to_subquery) { should eql('(SELECT * FROM "users" WHERE "id" = 1 ORDER BY "id" DESC, "name" DESC, "age" DESC)')                 }
  end

  context 'when the operand is a summarization' do
    context 'summarize per table dee' do
      let(:summarize_per) { TABLE_DEE                                                                                        }
      let(:operand)       { base_relation.summarize(summarize_per) { |r| r.add(:count, r.id.count) }.sort_by { |r| r.count } }

      it_should_behave_like 'a generated SQL SELECT query'

      its(:to_s)        { should eql('SELECT COUNT ("id") AS "count" FROM "users" ORDER BY "count" DESC')   }
      its(:to_subquery) { should eql('(SELECT COUNT ("id") AS "count" FROM "users" ORDER BY "count" DESC)') }
    end

    context 'summarize per table dum' do
      let(:summarize_per) { TABLE_DUM                                                                                        }
      let(:operand)       { base_relation.summarize(summarize_per) { |r| r.add(:count, r.id.count) }.sort_by { |r| r.count } }

      it_should_behave_like 'a generated SQL SELECT query'

      its(:to_s)        { should eql('SELECT COUNT ("id") AS "count" FROM "users" HAVING FALSE ORDER BY "count" DESC')   }
      its(:to_subquery) { should eql('(SELECT COUNT ("id") AS "count" FROM "users" HAVING FALSE ORDER BY "count" DESC)') }
    end

    context 'summarize by a subset of the operand header' do
      let(:operand) { base_relation.summarize([:id, :name]) { |r| r.add(:count, r.age.count) }.sort_by { |r| [r.id, r.name, r.count] } }

      it_should_behave_like 'a generated SQL SELECT query'

      its(:to_s)        { should eql('SELECT "id", "name", COUNT ("age") AS "count" FROM "users" GROUP BY "id", "name" HAVING COUNT (*) > 0 ORDER BY "id" DESC, "name" DESC, "count" DESC')   }
      its(:to_subquery) { should eql('(SELECT "id", "name", COUNT ("age") AS "count" FROM "users" GROUP BY "id", "name" HAVING COUNT (*) > 0 ORDER BY "id" DESC, "name" DESC, "count" DESC)') }
    end
  end

  context 'when the operand is sorted' do
    let(:operand) { base_relation.sort_by { |r| [r.id, r.name, r.age] } }

    it_should_behave_like 'a generated SQL SELECT query'

    its(:to_s)        { should eql('SELECT "id", "name", "age" FROM "users" ORDER BY "id" DESC, "name" DESC, "age" DESC') }
    its(:to_subquery) { should eql('(SELECT * FROM "users" ORDER BY "id" DESC, "name" DESC, "age" DESC)')                 }
  end

  context 'when the operand is reversed' do
    let(:operand) { base_relation.sort_by { |r| [r.id, r.name, r.age] }.reverse }

    it_should_behave_like 'a generated SQL SELECT query'

    its(:to_s)        { should eql('SELECT "id", "name", "age" FROM "users" ORDER BY "id", "name", "age"') }
    its(:to_subquery) { should eql('(SELECT * FROM "users" ORDER BY "id", "name", "age")')                 }
  end

  context 'when the operand is limited' do
    let(:operand) { base_relation.sort_by { |r| [r.id, r.name, r.age] }.take(1) }

    it_should_behave_like 'a generated SQL SELECT query'

    its(:to_s)        { should eql('SELECT "id", "name", "age" FROM (SELECT * FROM "users" ORDER BY "id", "name", "age" LIMIT 1) AS "users" ORDER BY "id" DESC, "name" DESC, "age" DESC') }
    its(:to_subquery) { should eql('(SELECT * FROM (SELECT * FROM "users" ORDER BY "id", "name", "age" LIMIT 1) AS "users" ORDER BY "id" DESC, "name" DESC, "age" DESC)')                 }
  end

  context 'when the operand is an offset' do
    let(:operand) { base_relation.sort_by { |r| [r.id, r.name, r.age] }.drop(1) }

    it_should_behave_like 'a generated SQL SELECT query'

    its(:to_s)        { should eql('SELECT "id", "name", "age" FROM (SELECT * FROM "users" ORDER BY "id", "name", "age" OFFSET 1) AS "users" ORDER BY "id" DESC, "name" DESC, "age" DESC') }
    its(:to_subquery) { should eql('(SELECT * FROM (SELECT * FROM "users" ORDER BY "id", "name", "age" OFFSET 1) AS "users" ORDER BY "id" DESC, "name" DESC, "age" DESC)')                 }
  end

  context 'when the operand is a difference' do
    let(:operand) { base_relation.difference(base_relation).sort_by { |r| [r.id, r.name, r.age] } }

    it_should_behave_like 'a generated SQL SELECT query'

    its(:to_s)        { should eql('SELECT "id", "name", "age" FROM ((SELECT "id", "name", "age" FROM "users") EXCEPT (SELECT "id", "name", "age" FROM "users")) AS "users" ORDER BY "id" DESC, "name" DESC, "age" DESC') }
    its(:to_subquery) { should eql('(SELECT * FROM ((SELECT "id", "name", "age" FROM "users") EXCEPT (SELECT "id", "name", "age" FROM "users")) AS "users" ORDER BY "id" DESC, "name" DESC, "age" DESC)')                 }
  end

  context 'when the operand is an intersection' do
    let(:operand) { base_relation.intersect(base_relation).sort_by { |r| [r.id, r.name, r.age] } }

    it_should_behave_like 'a generated SQL SELECT query'

    its(:to_s)        { should eql('SELECT "id", "name", "age" FROM ((SELECT "id", "name", "age" FROM "users") INTERSECT (SELECT "id", "name", "age" FROM "users")) AS "users" ORDER BY "id" DESC, "name" DESC, "age" DESC') }
    its(:to_subquery) { should eql('(SELECT * FROM ((SELECT "id", "name", "age" FROM "users") INTERSECT (SELECT "id", "name", "age" FROM "users")) AS "users" ORDER BY "id" DESC, "name" DESC, "age" DESC)')                 }
  end

  context 'when the operand is a union' do
    let(:operand) { base_relation.union(base_relation).sort_by { |r| [r.id, r.name, r.age] } }

    it_should_behave_like 'a generated SQL SELECT query'

    its(:to_s)        { should eql('SELECT "id", "name", "age" FROM ((SELECT "id", "name", "age" FROM "users") UNION (SELECT "id", "name", "age" FROM "users")) AS "users" ORDER BY "id" DESC, "name" DESC, "age" DESC') }
    its(:to_subquery) { should eql('(SELECT * FROM ((SELECT "id", "name", "age" FROM "users") UNION (SELECT "id", "name", "age" FROM "users")) AS "users" ORDER BY "id" DESC, "name" DESC, "age" DESC)')                 }
  end

  context 'when the operand is a join' do
    let(:operand) { base_relation.join(base_relation).sort_by { |r| [r.id, r.name, r.age] } }

    it_should_behave_like 'a generated SQL SELECT query'

    its(:to_s)        { should eql('SELECT "id", "name", "age" FROM (SELECT * FROM "users" AS "left" NATURAL JOIN "users" AS "right") AS "users" ORDER BY "id" DESC, "name" DESC, "age" DESC') }
    its(:to_subquery) { should eql('(SELECT * FROM (SELECT * FROM "users" AS "left" NATURAL JOIN "users" AS "right") AS "users" ORDER BY "id" DESC, "name" DESC, "age" DESC)')                 }
  end
end
