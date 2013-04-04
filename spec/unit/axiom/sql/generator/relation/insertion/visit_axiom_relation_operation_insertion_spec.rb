# encoding: utf-8

require 'spec_helper'

describe SQL::Generator::Relation::Insertion, '#visit_axiom_relation_operation_insertion' do
  subject { object.visit_axiom_relation_operation_insertion(insertion) }

  let(:object)        { described_class.new                              }
  let(:insertion)     { operand.insert(other)                            }
  let(:operand)       { Relation::Base.new(relation_name, header, body)  }
  let(:relation_name) { 'users'                                          }
  let(:header)        { [ id, name, age ]                                }
  let(:body)          { [].each                                          }
  let(:id)            { Attribute::Integer.new(:id)                      }
  let(:name)          { Attribute::String.new(:name)                     }
  let(:age)           { Attribute::Integer.new(:age, :required => false) }

  context 'inserting a non-empty materialized relation' do
    let(:other) { operand.materialize            }
    let(:body)  { [ [ 1, 'Dan Kubb', 36 ] ].each }

    it_should_behave_like 'a generated SQL expression'

    its(:to_s)        { should eql('INSERT INTO users ("id", "name", "age") VALUES (1, \'Dan Kubb\', 36)') }
    its(:to_subquery) { should eql('INSERT INTO users ("id", "name", "age") VALUES (1, \'Dan Kubb\', 36)') }
  end

  context 'inserting an empty materialized relation' do
    let(:other) { operand.materialize }

    it_should_behave_like 'a generated SQL expression'

    its(:to_s)        { should eql('INSERT INTO users ("id", "name", "age") SELECT 0 LIMIT 0') }
    its(:to_subquery) { should eql('INSERT INTO users ("id", "name", "age") SELECT 0 LIMIT 0') }
  end

  context 'inserting a base relation' do
    let(:other) { operand }

    it_should_behave_like 'a generated SQL expression'

    its(:to_s)        { should eql('INSERT INTO users ("id", "name", "age") SELECT "id", "name", "age" FROM "users"') }
    its(:to_subquery) { should eql('INSERT INTO users ("id", "name", "age") SELECT "id", "name", "age" FROM "users"') }
  end

  context 'inserting a projection' do
    let(:header) { [ id, name ]                    }
    let(:other)  { operand.project([ :id, :name ]) }

    it_should_behave_like 'a generated SQL SELECT query'

    its(:to_s)        { should eql('INSERT INTO users ("id", "name") SELECT DISTINCT "id", "name" FROM "users"') }
    its(:to_subquery) { should eql('INSERT INTO users ("id", "name") SELECT DISTINCT "id", "name" FROM "users"') }
  end

  context 'inserting an extension' do
    let(:other) { Relation::Base.new('other', [ id, name ], body).extend { |r| r.add(age, 1) } }

    it_should_behave_like 'a generated SQL SELECT query'

    its(:to_s)        { should eql('INSERT INTO users ("id", "name", "age") SELECT "id", "name", 1 AS "age" FROM "other"') }
    its(:to_subquery) { should eql('INSERT INTO users ("id", "name", "age") SELECT "id", "name", 1 AS "age" FROM "other"') }
  end

  context 'inserting a rename' do
    let(:other) { Relation::Base.new('other', [ [ :other_id, Integer ], name, age ], body).rename(:other_id => :id) }

    it_should_behave_like 'a generated SQL SELECT query'

    its(:to_s)        { should eql('INSERT INTO users ("id", "name", "age") SELECT "other_id" AS "id", "name", "age" FROM "other"') }
    its(:to_subquery) { should eql('INSERT INTO users ("id", "name", "age") SELECT "other_id" AS "id", "name", "age" FROM "other"') }
  end

  context 'inserting a restriction' do
    let(:other) { operand.restrict { |r| r.id.eq(1) } }

    it_should_behave_like 'a generated SQL SELECT query'

    its(:to_s)        { should eql('INSERT INTO users ("id", "name", "age") SELECT "id", "name", "age" FROM "users" WHERE "id" = 1') }
    its(:to_subquery) { should eql('INSERT INTO users ("id", "name", "age") SELECT "id", "name", "age" FROM "users" WHERE "id" = 1') }
  end

  context 'inserting a summarization' do
    context 'summarize per table dee' do
      let(:summarize_per) { TABLE_DEE                                                      }
      let(:operand)       { Relation::Base.new(relation_name, [ id ], body)                }
      let(:other)         { operand.summarize(summarize_per) { |r| r.add(id, r.id.count) } }

      it_should_behave_like 'a generated SQL SELECT query'

      its(:to_s)        { should eql('INSERT INTO users ("id") SELECT COUNT ("id") AS "id" FROM "users"') }
      its(:to_subquery) { should eql('INSERT INTO users ("id") SELECT COUNT ("id") AS "id" FROM "users"') }
    end

    context 'summarize per table dum' do
      let(:summarize_per) { TABLE_DUM                                                      }
      let(:operand)       { Relation::Base.new(relation_name, [ id ], body)                }
      let(:other)         { operand.summarize(summarize_per) { |r| r.add(id, r.id.count) } }

      it_should_behave_like 'a generated SQL SELECT query'

      its(:to_s)        { should eql('INSERT INTO users ("id") SELECT COUNT ("id") AS "id" FROM "users" HAVING FALSE') }
      its(:to_subquery) { should eql('INSERT INTO users ("id") SELECT COUNT ("id") AS "id" FROM "users" HAVING FALSE') }
    end

    context 'summarize by a subset of the operand header' do
      let(:other) { operand.summarize([ :id, :name ]) { |r| r.add(age, r.age.count) } }

      it_should_behave_like 'a generated SQL SELECT query'

      its(:to_s)        { should eql('INSERT INTO users ("id", "name", "age") SELECT "id", "name", COUNT ("age") AS "age" FROM "users" GROUP BY "id", "name" HAVING COUNT (*) > 0') }
      its(:to_subquery) { should eql('INSERT INTO users ("id", "name", "age") SELECT "id", "name", COUNT ("age") AS "age" FROM "users" GROUP BY "id", "name" HAVING COUNT (*) > 0') }
    end
  end

  context 'inserting an order' do
    let(:other) { operand.sort_by { |r| [ r.id, r.name, r.age ] } }

    it_should_behave_like 'a generated SQL SELECT query'

    its(:to_s)        { should eql('INSERT INTO users ("id", "name", "age") SELECT "id", "name", "age" FROM "users" ORDER BY "id", "name", "age"') }
    its(:to_subquery) { should eql('INSERT INTO users ("id", "name", "age") SELECT "id", "name", "age" FROM "users" ORDER BY "id", "name", "age"') }
  end

  context 'inserting a reverse' do
    let(:other) { operand.sort_by { |r| [ r.id, r.name, r.age ] }.reverse }

    it_should_behave_like 'a generated SQL SELECT query'

    its(:to_s)        { should eql('INSERT INTO users ("id", "name", "age") SELECT "id", "name", "age" FROM "users" ORDER BY "id" DESC, "name" DESC, "age" DESC') }
    its(:to_subquery) { should eql('INSERT INTO users ("id", "name", "age") SELECT "id", "name", "age" FROM "users" ORDER BY "id" DESC, "name" DESC, "age" DESC') }
  end

  context 'inserting a limit' do
    let(:other) { operand.sort_by { |r| [ r.id, r.name, r.age ] }.take(1) }

    it_should_behave_like 'a generated SQL SELECT query'

    its(:to_s)        { should eql('INSERT INTO users ("id", "name", "age") SELECT "id", "name", "age" FROM "users" ORDER BY "id", "name", "age" LIMIT 1') }
    its(:to_subquery) { should eql('INSERT INTO users ("id", "name", "age") SELECT "id", "name", "age" FROM "users" ORDER BY "id", "name", "age" LIMIT 1') }
  end

  context 'inserting an offset' do
    let(:other) { operand.sort_by { |r| [ r.id, r.name, r.age ] }.drop(1) }

    it_should_behave_like 'a generated SQL SELECT query'

    its(:to_s)        { should eql('INSERT INTO users ("id", "name", "age") SELECT "id", "name", "age" FROM "users" ORDER BY "id", "name", "age" OFFSET 1') }
    its(:to_subquery) { should eql('INSERT INTO users ("id", "name", "age") SELECT "id", "name", "age" FROM "users" ORDER BY "id", "name", "age" OFFSET 1') }
  end

  context 'inserting a difference' do
    let(:other) { operand.difference(operand) }

    it_should_behave_like 'a generated SQL SELECT query'

    its(:to_s)        { should eql('INSERT INTO users ("id", "name", "age") (SELECT "id", "name", "age" FROM "users") EXCEPT (SELECT "id", "name", "age" FROM "users")') }
    its(:to_subquery) { should eql('INSERT INTO users ("id", "name", "age") (SELECT "id", "name", "age" FROM "users") EXCEPT (SELECT "id", "name", "age" FROM "users")') }
  end

  context 'inserting a intersection' do
    let(:other) { operand.intersect(operand) }

    it_should_behave_like 'a generated SQL SELECT query'

    its(:to_s)        { should eql('INSERT INTO users ("id", "name", "age") (SELECT "id", "name", "age" FROM "users") INTERSECT (SELECT "id", "name", "age" FROM "users")') }
    its(:to_subquery) { should eql('INSERT INTO users ("id", "name", "age") (SELECT "id", "name", "age" FROM "users") INTERSECT (SELECT "id", "name", "age" FROM "users")') }
  end

  context 'inserting a union' do
    let(:other) { operand.union(operand) }

    it_should_behave_like 'a generated SQL SELECT query'

    its(:to_s)        { should eql('INSERT INTO users ("id", "name", "age") (SELECT "id", "name", "age" FROM "users") UNION (SELECT "id", "name", "age" FROM "users")') }
    its(:to_subquery) { should eql('INSERT INTO users ("id", "name", "age") (SELECT "id", "name", "age" FROM "users") UNION (SELECT "id", "name", "age" FROM "users")') }
  end

  context 'inserting a join' do
    let(:other) { operand.join(operand) }

    it_should_behave_like 'a generated SQL SELECT query'

    its(:to_s)        { should eql('INSERT INTO users ("id", "name", "age") SELECT "id", "name", "age" FROM "users" AS "left" NATURAL JOIN "users" AS "right"') }
    its(:to_subquery) { should eql('INSERT INTO users ("id", "name", "age") SELECT "id", "name", "age" FROM "users" AS "left" NATURAL JOIN "users" AS "right"') }
  end
end
