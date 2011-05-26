# encoding: utf-8

require 'spec_helper'

describe SQL::Generator::Relation::Unary, '#visit_veritas_algebra_summarization' do
  subject { object.visit_veritas_algebra_summarization(summarization) }

  let(:relation_name)  { 'users'                                          }
  let(:id)             { Attribute::Integer.new(:id)                      }
  let(:name)           { Attribute::String.new(:name)                     }
  let(:age)            { Attribute::Integer.new(:age, :required => false) }
  let(:header)         { [ id, name, age ]                                }
  let(:body)           { [ [ 1, 'Dan Kubb', 35 ] ].each                   }
  let(:base_relation)  { Relation::Base.new(relation_name, header, body)  }
  let(:other_relation) { Relation::Base.new('other', [ id ], [ [ 1 ] ])   }
  let(:object)         { described_class.new                              }

  context 'summarize per table dee' do
    let(:summarize_per) { TABLE_DEE                                                             }
    let(:summarization) { operand.summarize(summarize_per) { |r| r.add(:count, r[:age].count) } }

    context 'when the operand is a base relation' do
      let(:operand) { base_relation }

      it_should_behave_like 'a generated SQL SELECT query'

      its(:to_s)        { should eql('SELECT COALESCE (COUNT ("age"), 0) AS "count" FROM "users"')   }
      its(:to_subquery) { should eql('(SELECT COALESCE (COUNT ("age"), 0) AS "count" FROM "users")') }
    end

    context 'when the operand is an extension' do
      let(:operand) { base_relation.extend { |r| r.add(:one, 1) } }

      it_should_behave_like 'a generated SQL SELECT query'

      its(:to_s)        { should eql('SELECT COALESCE (COUNT ("age"), 0) AS "count" FROM (SELECT *, 1 AS "one" FROM "users") AS "users"')   }
      its(:to_subquery) { should eql('(SELECT COALESCE (COUNT ("age"), 0) AS "count" FROM (SELECT *, 1 AS "one" FROM "users") AS "users")') }
    end

    context 'when the operand is a projection' do
      let(:operand)       { base_relation.project([ :id, :name ])                                }
      let(:summarization) { operand.summarize(summarize_per) { |r| r.add(:count, r[:id].count) } }

      it_should_behave_like 'a generated SQL SELECT query'

      its(:to_s)        { should eql('SELECT COALESCE (COUNT ("id"), 0) AS "count" FROM (SELECT DISTINCT "id", "name" FROM "users") AS "users"')   }
      its(:to_subquery) { should eql('(SELECT COALESCE (COUNT ("id"), 0) AS "count" FROM (SELECT DISTINCT "id", "name" FROM "users") AS "users")') }
    end

    context 'when the operand is a rename' do
      let(:operand) { base_relation.rename(:name => :other_name) }

      it_should_behave_like 'a generated SQL SELECT query'

      its(:to_s)        { should eql('SELECT COALESCE (COUNT ("age"), 0) AS "count" FROM (SELECT "id", "name" AS "other_name", "age" FROM "users") AS "users"')   }
      its(:to_subquery) { should eql('(SELECT COALESCE (COUNT ("age"), 0) AS "count" FROM (SELECT "id", "name" AS "other_name", "age" FROM "users") AS "users")') }
    end

    context 'when the operand is a restriction' do
      let(:operand) { base_relation.restrict { |r| r[:id].eq(1) } }

      it_should_behave_like 'a generated SQL SELECT query'

      its(:to_s)        { should eql('SELECT COALESCE (COUNT ("age"), 0) AS "count" FROM (SELECT * FROM "users" WHERE "id" = 1) AS "users"')   }
      its(:to_subquery) { should eql('(SELECT COALESCE (COUNT ("age"), 0) AS "count" FROM (SELECT * FROM "users" WHERE "id" = 1) AS "users")') }
    end

    context 'when the operand is a summarization' do
      let(:operand)       { base_relation.summarize([ :id ]) { |r| r.add(:count, r[:age].count) }   }
      let(:summarization) { operand.summarize(summarize_per) { |r| r.add(:count, r[:count].count) } }

      it_should_behave_like 'a generated SQL SELECT query'

      its(:to_s)        { should eql('SELECT COALESCE (COUNT ("count"), 0) AS "count" FROM (SELECT "id", COALESCE (COUNT ("age"), 0) AS "count" FROM "users" GROUP BY "id" HAVING COUNT (*) > 0) AS "users"')   }
      its(:to_subquery) { should eql('(SELECT COALESCE (COUNT ("count"), 0) AS "count" FROM (SELECT "id", COALESCE (COUNT ("age"), 0) AS "count" FROM "users" GROUP BY "id" HAVING COUNT (*) > 0) AS "users")') }
    end

    context 'when the operand is ordered' do
      let(:operand) { base_relation.order }

      it_should_behave_like 'a generated SQL SELECT query'

      its(:to_s)        { should eql('SELECT COALESCE (COUNT ("age"), 0) AS "count" FROM (SELECT * FROM "users" ORDER BY "id", "name", "age") AS "users"')   }
      its(:to_subquery) { should eql('(SELECT COALESCE (COUNT ("age"), 0) AS "count" FROM (SELECT * FROM "users" ORDER BY "id", "name", "age") AS "users")') }
    end

    context 'when the operand is reversed' do
      let(:operand) { base_relation.order.reverse }

      it_should_behave_like 'a generated SQL SELECT query'

      its(:to_s)        { should eql('SELECT COALESCE (COUNT ("age"), 0) AS "count" FROM (SELECT * FROM "users" ORDER BY "id" DESC, "name" DESC, "age" DESC) AS "users"')   }
      its(:to_subquery) { should eql('(SELECT COALESCE (COUNT ("age"), 0) AS "count" FROM (SELECT * FROM "users" ORDER BY "id" DESC, "name" DESC, "age" DESC) AS "users")') }
    end

    context 'when the operand is limited' do
      let(:operand) { base_relation.order.take(1) }

      it_should_behave_like 'a generated SQL SELECT query'

      its(:to_s)        { should eql('SELECT COALESCE (COUNT ("age"), 0) AS "count" FROM (SELECT * FROM "users" ORDER BY "id", "name", "age" LIMIT 1) AS "users"')   }
      its(:to_subquery) { should eql('(SELECT COALESCE (COUNT ("age"), 0) AS "count" FROM (SELECT * FROM "users" ORDER BY "id", "name", "age" LIMIT 1) AS "users")') }
    end

    context 'when the operand is an offset' do
      let(:operand) { base_relation.order.drop(1) }

      it_should_behave_like 'a generated SQL SELECT query'

      its(:to_s)        { should eql('SELECT COALESCE (COUNT ("age"), 0) AS "count" FROM (SELECT * FROM "users" ORDER BY "id", "name", "age" OFFSET 1) AS "users"')   }
      its(:to_subquery) { should eql('(SELECT COALESCE (COUNT ("age"), 0) AS "count" FROM (SELECT * FROM "users" ORDER BY "id", "name", "age" OFFSET 1) AS "users")') }
    end

    context 'when the operand is a difference' do
      let(:operand) { base_relation.difference(base_relation) }

      it_should_behave_like 'a generated SQL SELECT query'

      its(:to_s)        { should eql('SELECT COALESCE (COUNT ("age"), 0) AS "count" FROM ((SELECT "id", "name", "age" FROM "users") EXCEPT (SELECT "id", "name", "age" FROM "users")) AS "users"')   }
      its(:to_subquery) { should eql('(SELECT COALESCE (COUNT ("age"), 0) AS "count" FROM ((SELECT "id", "name", "age" FROM "users") EXCEPT (SELECT "id", "name", "age" FROM "users")) AS "users")') }
    end

    context 'when the operand is an intersection' do
      let(:operand) { base_relation.intersect(base_relation) }

      it_should_behave_like 'a generated SQL SELECT query'

      its(:to_s)        { should eql('SELECT COALESCE (COUNT ("age"), 0) AS "count" FROM ((SELECT "id", "name", "age" FROM "users") INTERSECT (SELECT "id", "name", "age" FROM "users")) AS "users"')   }
      its(:to_subquery) { should eql('(SELECT COALESCE (COUNT ("age"), 0) AS "count" FROM ((SELECT "id", "name", "age" FROM "users") INTERSECT (SELECT "id", "name", "age" FROM "users")) AS "users")') }
    end

    context 'when the operand is a union' do
      let(:operand) { base_relation.union(base_relation) }

      it_should_behave_like 'a generated SQL SELECT query'

      its(:to_s)        { should eql('SELECT COALESCE (COUNT ("age"), 0) AS "count" FROM ((SELECT "id", "name", "age" FROM "users") UNION (SELECT "id", "name", "age" FROM "users")) AS "users"')   }
      its(:to_subquery) { should eql('(SELECT COALESCE (COUNT ("age"), 0) AS "count" FROM ((SELECT "id", "name", "age" FROM "users") UNION (SELECT "id", "name", "age" FROM "users")) AS "users")') }
    end

    context 'when the operand is a join' do
      let(:operand) { base_relation.join(base_relation) }

      it_should_behave_like 'a generated SQL SELECT query'

      its(:to_s)        { should eql('SELECT COALESCE (COUNT ("age"), 0) AS "count" FROM (SELECT * FROM "users" AS "left" NATURAL JOIN "users" AS "right") AS "users"')   }
      its(:to_subquery) { should eql('(SELECT COALESCE (COUNT ("age"), 0) AS "count" FROM (SELECT * FROM "users" AS "left" NATURAL JOIN "users" AS "right") AS "users")') }
    end
  end

  context 'summarize per table dum' do
    let(:summarize_per) { TABLE_DUM                                                             }
    let(:summarization) { operand.summarize(summarize_per) { |r| r.add(:count, r[:age].count) } }

    context 'when the operand is a base relation' do
      let(:operand) { base_relation }

      it_should_behave_like 'a generated SQL SELECT query'

      its(:to_s)        { should eql('SELECT COALESCE (COUNT ("age"), 0) AS "count" FROM "users" HAVING 1 = 0')   }
      its(:to_subquery) { should eql('(SELECT COALESCE (COUNT ("age"), 0) AS "count" FROM "users" HAVING 1 = 0)') }
    end

    context 'when the operand is an extension' do
      let(:operand) { base_relation.extend { |r| r.add(:one, 1) } }

      it_should_behave_like 'a generated SQL SELECT query'

      its(:to_s)        { should eql('SELECT COALESCE (COUNT ("age"), 0) AS "count" FROM (SELECT *, 1 AS "one" FROM "users") AS "users" HAVING 1 = 0')   }
      its(:to_subquery) { should eql('(SELECT COALESCE (COUNT ("age"), 0) AS "count" FROM (SELECT *, 1 AS "one" FROM "users") AS "users" HAVING 1 = 0)') }
    end

    context 'when the operand is a projection' do
      let(:operand)       { base_relation.project([ :id, :name ])                                }
      let(:summarization) { operand.summarize(summarize_per) { |r| r.add(:count, r[:id].count) } }

      it_should_behave_like 'a generated SQL SELECT query'

      its(:to_s)        { should eql('SELECT COALESCE (COUNT ("id"), 0) AS "count" FROM (SELECT DISTINCT "id", "name" FROM "users") AS "users" HAVING 1 = 0')   }
      its(:to_subquery) { should eql('(SELECT COALESCE (COUNT ("id"), 0) AS "count" FROM (SELECT DISTINCT "id", "name" FROM "users") AS "users" HAVING 1 = 0)') }
    end

    context 'when the operand is a rename' do
      let(:operand) { base_relation.rename(:name => :other_name) }

      it_should_behave_like 'a generated SQL SELECT query'

      its(:to_s)        { should eql('SELECT COALESCE (COUNT ("age"), 0) AS "count" FROM (SELECT "id", "name" AS "other_name", "age" FROM "users") AS "users" HAVING 1 = 0')   }
      its(:to_subquery) { should eql('(SELECT COALESCE (COUNT ("age"), 0) AS "count" FROM (SELECT "id", "name" AS "other_name", "age" FROM "users") AS "users" HAVING 1 = 0)') }
    end

    context 'when the operand is a restriction' do
      let(:operand) { base_relation.restrict { |r| r[:id].eq(1) } }

      it_should_behave_like 'a generated SQL SELECT query'

      its(:to_s)        { should eql('SELECT COALESCE (COUNT ("age"), 0) AS "count" FROM (SELECT * FROM "users" WHERE "id" = 1) AS "users" HAVING 1 = 0')   }
      its(:to_subquery) { should eql('(SELECT COALESCE (COUNT ("age"), 0) AS "count" FROM (SELECT * FROM "users" WHERE "id" = 1) AS "users" HAVING 1 = 0)') }
    end

    context 'when the operand is a summarization' do
      let(:operand)       { base_relation.summarize([ :id ]) { |r| r.add(:count, r[:age].count) }   }
      let(:summarization) { operand.summarize(summarize_per) { |r| r.add(:count, r[:count].count) } }

      it_should_behave_like 'a generated SQL SELECT query'

      its(:to_s)        { should eql('SELECT COALESCE (COUNT ("count"), 0) AS "count" FROM (SELECT "id", COALESCE (COUNT ("age"), 0) AS "count" FROM "users" GROUP BY "id" HAVING COUNT (*) > 0) AS "users" HAVING 1 = 0')   }
      its(:to_subquery) { should eql('(SELECT COALESCE (COUNT ("count"), 0) AS "count" FROM (SELECT "id", COALESCE (COUNT ("age"), 0) AS "count" FROM "users" GROUP BY "id" HAVING COUNT (*) > 0) AS "users" HAVING 1 = 0)') }
    end

    context 'when the operand is ordered' do
      let(:operand) { base_relation.order }

      it_should_behave_like 'a generated SQL SELECT query'

      its(:to_s)        { should eql('SELECT COALESCE (COUNT ("age"), 0) AS "count" FROM (SELECT * FROM "users" ORDER BY "id", "name", "age") AS "users" HAVING 1 = 0')   }
      its(:to_subquery) { should eql('(SELECT COALESCE (COUNT ("age"), 0) AS "count" FROM (SELECT * FROM "users" ORDER BY "id", "name", "age") AS "users" HAVING 1 = 0)') }
    end

    context 'when the operand is reversed' do
      let(:operand) { base_relation.order.reverse }

      it_should_behave_like 'a generated SQL SELECT query'

      its(:to_s)        { should eql('SELECT COALESCE (COUNT ("age"), 0) AS "count" FROM (SELECT * FROM "users" ORDER BY "id" DESC, "name" DESC, "age" DESC) AS "users" HAVING 1 = 0')   }
      its(:to_subquery) { should eql('(SELECT COALESCE (COUNT ("age"), 0) AS "count" FROM (SELECT * FROM "users" ORDER BY "id" DESC, "name" DESC, "age" DESC) AS "users" HAVING 1 = 0)') }
    end

    context 'when the operand is limited' do
      let(:operand) { base_relation.order.take(1) }

      it_should_behave_like 'a generated SQL SELECT query'

      its(:to_s)        { should eql('SELECT COALESCE (COUNT ("age"), 0) AS "count" FROM (SELECT * FROM "users" ORDER BY "id", "name", "age" LIMIT 1) AS "users" HAVING 1 = 0')   }
      its(:to_subquery) { should eql('(SELECT COALESCE (COUNT ("age"), 0) AS "count" FROM (SELECT * FROM "users" ORDER BY "id", "name", "age" LIMIT 1) AS "users" HAVING 1 = 0)') }
    end

    context 'when the operand is an offset' do
      let(:operand) { base_relation.order.drop(1) }

      it_should_behave_like 'a generated SQL SELECT query'

      its(:to_s)        { should eql('SELECT COALESCE (COUNT ("age"), 0) AS "count" FROM (SELECT * FROM "users" ORDER BY "id", "name", "age" OFFSET 1) AS "users" HAVING 1 = 0')   }
      its(:to_subquery) { should eql('(SELECT COALESCE (COUNT ("age"), 0) AS "count" FROM (SELECT * FROM "users" ORDER BY "id", "name", "age" OFFSET 1) AS "users" HAVING 1 = 0)') }
    end

    context 'when the operand is a difference' do
      let(:operand) { base_relation.difference(base_relation) }

      it_should_behave_like 'a generated SQL SELECT query'

      its(:to_s)        { should eql('SELECT COALESCE (COUNT ("age"), 0) AS "count" FROM ((SELECT "id", "name", "age" FROM "users") EXCEPT (SELECT "id", "name", "age" FROM "users")) AS "users" HAVING 1 = 0')   }
      its(:to_subquery) { should eql('(SELECT COALESCE (COUNT ("age"), 0) AS "count" FROM ((SELECT "id", "name", "age" FROM "users") EXCEPT (SELECT "id", "name", "age" FROM "users")) AS "users" HAVING 1 = 0)') }
    end

    context 'when the operand is an intersection' do
      let(:operand) { base_relation.intersect(base_relation) }

      it_should_behave_like 'a generated SQL SELECT query'

      its(:to_s)        { should eql('SELECT COALESCE (COUNT ("age"), 0) AS "count" FROM ((SELECT "id", "name", "age" FROM "users") INTERSECT (SELECT "id", "name", "age" FROM "users")) AS "users" HAVING 1 = 0')   }
      its(:to_subquery) { should eql('(SELECT COALESCE (COUNT ("age"), 0) AS "count" FROM ((SELECT "id", "name", "age" FROM "users") INTERSECT (SELECT "id", "name", "age" FROM "users")) AS "users" HAVING 1 = 0)') }
    end

    context 'when the operand is a union' do
      let(:operand) { base_relation.union(base_relation) }

      it_should_behave_like 'a generated SQL SELECT query'

      its(:to_s)        { should eql('SELECT COALESCE (COUNT ("age"), 0) AS "count" FROM ((SELECT "id", "name", "age" FROM "users") UNION (SELECT "id", "name", "age" FROM "users")) AS "users" HAVING 1 = 0')   }
      its(:to_subquery) { should eql('(SELECT COALESCE (COUNT ("age"), 0) AS "count" FROM ((SELECT "id", "name", "age" FROM "users") UNION (SELECT "id", "name", "age" FROM "users")) AS "users" HAVING 1 = 0)') }
    end

    context 'when the operand is a join' do
      let(:operand) { base_relation.join(base_relation) }

      it_should_behave_like 'a generated SQL SELECT query'

      its(:to_s)        { should eql('SELECT COALESCE (COUNT ("age"), 0) AS "count" FROM (SELECT * FROM "users" AS "left" NATURAL JOIN "users" AS "right") AS "users" HAVING 1 = 0')   }
      its(:to_subquery) { should eql('(SELECT COALESCE (COUNT ("age"), 0) AS "count" FROM (SELECT * FROM "users" AS "left" NATURAL JOIN "users" AS "right") AS "users" HAVING 1 = 0)') }
    end
  end

  context 'summarize by a subset of the operand header' do
    let(:summarize_by)  { [ :id ]                                                              }
    let(:summarization) { operand.summarize(summarize_by) { |r| r.add(:count, r[:age].count) } }

    context 'when the operand is a base relation' do
      let(:operand) { base_relation }

      it_should_behave_like 'a generated SQL SELECT query'

      its(:to_s)        { should eql('SELECT "id", COALESCE (COUNT ("age"), 0) AS "count" FROM "users" GROUP BY "id" HAVING COUNT (*) > 0')   }
      its(:to_subquery) { should eql('(SELECT "id", COALESCE (COUNT ("age"), 0) AS "count" FROM "users" GROUP BY "id" HAVING COUNT (*) > 0)') }
    end

    context 'when the operand is a projection' do
      let(:operand)       { base_relation.project([ :id, :name ])                                 }
      let(:summarization) { operand.summarize(summarize_by) { |r| r.add(:count, r[:name].count) } }

      it_should_behave_like 'a generated SQL SELECT query'

      its(:to_s)        { should eql('SELECT "id", COALESCE (COUNT ("name"), 0) AS "count" FROM (SELECT DISTINCT "id", "name" FROM "users") AS "users" GROUP BY "id" HAVING COUNT (*) > 0')   }
      its(:to_subquery) { should eql('(SELECT "id", COALESCE (COUNT ("name"), 0) AS "count" FROM (SELECT DISTINCT "id", "name" FROM "users") AS "users" GROUP BY "id" HAVING COUNT (*) > 0)') }
    end

    context 'when the operand is an extension' do
      let(:operand) { base_relation.extend { |r| r.add(:one, 1) } }

      it_should_behave_like 'a generated SQL SELECT query'

      its(:to_s)        { should eql('SELECT "id", COALESCE (COUNT ("age"), 0) AS "count" FROM (SELECT *, 1 AS "one" FROM "users") AS "users" GROUP BY "id" HAVING COUNT (*) > 0')   }
      its(:to_subquery) { should eql('(SELECT "id", COALESCE (COUNT ("age"), 0) AS "count" FROM (SELECT *, 1 AS "one" FROM "users") AS "users" GROUP BY "id" HAVING COUNT (*) > 0)') }
    end

    context 'when the operand is a rename' do
      let(:operand) { base_relation.rename(:name => :other_name) }

      it_should_behave_like 'a generated SQL SELECT query'

      its(:to_s)        { should eql('SELECT "id", COALESCE (COUNT ("age"), 0) AS "count" FROM (SELECT "id", "name" AS "other_name", "age" FROM "users") AS "users" GROUP BY "id" HAVING COUNT (*) > 0')   }
      its(:to_subquery) { should eql('(SELECT "id", COALESCE (COUNT ("age"), 0) AS "count" FROM (SELECT "id", "name" AS "other_name", "age" FROM "users") AS "users" GROUP BY "id" HAVING COUNT (*) > 0)') }
    end

    context 'when the operand is a restriction' do
      let(:operand) { base_relation.restrict { |r| r[:id].eq(1) } }

      it_should_behave_like 'a generated SQL SELECT query'

      its(:to_s)        { should eql('SELECT "id", COALESCE (COUNT ("age"), 0) AS "count" FROM (SELECT * FROM "users" WHERE "id" = 1) AS "users" GROUP BY "id" HAVING COUNT (*) > 0')   }
      its(:to_subquery) { should eql('(SELECT "id", COALESCE (COUNT ("age"), 0) AS "count" FROM (SELECT * FROM "users" WHERE "id" = 1) AS "users" GROUP BY "id" HAVING COUNT (*) > 0)') }
    end

    context 'when the operand is ordered' do
      let(:operand) { base_relation.order }

      it_should_behave_like 'a generated SQL SELECT query'

      its(:to_s)        { should eql('SELECT "id", COALESCE (COUNT ("age"), 0) AS "count" FROM (SELECT * FROM "users" ORDER BY "id", "name", "age") AS "users" GROUP BY "id" HAVING COUNT (*) > 0')   }
      its(:to_subquery) { should eql('(SELECT "id", COALESCE (COUNT ("age"), 0) AS "count" FROM (SELECT * FROM "users" ORDER BY "id", "name", "age") AS "users" GROUP BY "id" HAVING COUNT (*) > 0)') }
    end

    context 'when the operand is reversed' do
      let(:operand) { base_relation.order.reverse }

      it_should_behave_like 'a generated SQL SELECT query'

      its(:to_s)        { should eql('SELECT "id", COALESCE (COUNT ("age"), 0) AS "count" FROM (SELECT * FROM "users" ORDER BY "id" DESC, "name" DESC, "age" DESC) AS "users" GROUP BY "id" HAVING COUNT (*) > 0')   }
      its(:to_subquery) { should eql('(SELECT "id", COALESCE (COUNT ("age"), 0) AS "count" FROM (SELECT * FROM "users" ORDER BY "id" DESC, "name" DESC, "age" DESC) AS "users" GROUP BY "id" HAVING COUNT (*) > 0)') }
    end

    context 'when the operand is limited' do
      let(:operand) { base_relation.order.take(1) }

      it_should_behave_like 'a generated SQL SELECT query'

      its(:to_s)        { should eql('SELECT "id", COALESCE (COUNT ("age"), 0) AS "count" FROM (SELECT * FROM "users" ORDER BY "id", "name", "age" LIMIT 1) AS "users" GROUP BY "id" HAVING COUNT (*) > 0')   }
      its(:to_subquery) { should eql('(SELECT "id", COALESCE (COUNT ("age"), 0) AS "count" FROM (SELECT * FROM "users" ORDER BY "id", "name", "age" LIMIT 1) AS "users" GROUP BY "id" HAVING COUNT (*) > 0)') }
    end

    context 'when the operand is an offset' do
      let(:operand) { base_relation.order.drop(1) }

      it_should_behave_like 'a generated SQL SELECT query'

      its(:to_s)        { should eql('SELECT "id", COALESCE (COUNT ("age"), 0) AS "count" FROM (SELECT * FROM "users" ORDER BY "id", "name", "age" OFFSET 1) AS "users" GROUP BY "id" HAVING COUNT (*) > 0')   }
      its(:to_subquery) { should eql('(SELECT "id", COALESCE (COUNT ("age"), 0) AS "count" FROM (SELECT * FROM "users" ORDER BY "id", "name", "age" OFFSET 1) AS "users" GROUP BY "id" HAVING COUNT (*) > 0)') }
    end

    context 'when the operand is a difference' do
      let(:operand) { base_relation.difference(base_relation) }

      it_should_behave_like 'a generated SQL SELECT query'

      its(:to_s)        { should eql('SELECT "id", COALESCE (COUNT ("age"), 0) AS "count" FROM ((SELECT "id", "name", "age" FROM "users") EXCEPT (SELECT "id", "name", "age" FROM "users")) AS "users" GROUP BY "id" HAVING COUNT (*) > 0')   }
      its(:to_subquery) { should eql('(SELECT "id", COALESCE (COUNT ("age"), 0) AS "count" FROM ((SELECT "id", "name", "age" FROM "users") EXCEPT (SELECT "id", "name", "age" FROM "users")) AS "users" GROUP BY "id" HAVING COUNT (*) > 0)') }
    end

    context 'when the operand is an intersection' do
      let(:operand) { base_relation.intersect(base_relation) }

      it_should_behave_like 'a generated SQL SELECT query'

      its(:to_s)        { should eql('SELECT "id", COALESCE (COUNT ("age"), 0) AS "count" FROM ((SELECT "id", "name", "age" FROM "users") INTERSECT (SELECT "id", "name", "age" FROM "users")) AS "users" GROUP BY "id" HAVING COUNT (*) > 0')   }
      its(:to_subquery) { should eql('(SELECT "id", COALESCE (COUNT ("age"), 0) AS "count" FROM ((SELECT "id", "name", "age" FROM "users") INTERSECT (SELECT "id", "name", "age" FROM "users")) AS "users" GROUP BY "id" HAVING COUNT (*) > 0)') }
    end

    context 'when the operand is a union' do
      let(:operand) { base_relation.union(base_relation) }

      it_should_behave_like 'a generated SQL SELECT query'

      its(:to_s)        { should eql('SELECT "id", COALESCE (COUNT ("age"), 0) AS "count" FROM ((SELECT "id", "name", "age" FROM "users") UNION (SELECT "id", "name", "age" FROM "users")) AS "users" GROUP BY "id" HAVING COUNT (*) > 0')   }
      its(:to_subquery) { should eql('(SELECT "id", COALESCE (COUNT ("age"), 0) AS "count" FROM ((SELECT "id", "name", "age" FROM "users") UNION (SELECT "id", "name", "age" FROM "users")) AS "users" GROUP BY "id" HAVING COUNT (*) > 0)') }
    end

    context 'when the operand is a join' do
      let(:operand) { base_relation.join(base_relation) }

      it_should_behave_like 'a generated SQL SELECT query'

      its(:to_s)        { should eql('SELECT "id", COALESCE (COUNT ("age"), 0) AS "count" FROM (SELECT * FROM "users" AS "left" NATURAL JOIN "users" AS "right") AS "users" GROUP BY "id" HAVING COUNT (*) > 0')   }
      its(:to_subquery) { should eql('(SELECT "id", COALESCE (COUNT ("age"), 0) AS "count" FROM (SELECT * FROM "users" AS "left" NATURAL JOIN "users" AS "right") AS "users" GROUP BY "id" HAVING COUNT (*) > 0)') }
    end
  end

  context 'summarize per another base relation' do
    let(:summarize_per) { other_relation                                                        }
    let(:summarization) { operand.summarize(summarize_per) { |r| r.add(:count, r[:age].count) } }

    context 'when the operand is a base relation' do
      let(:operand) { base_relation }

      it_should_behave_like 'a generated SQL SELECT query'

      its(:to_s)        { should eql('SELECT "id", COALESCE (COUNT ("age"), 0) AS "count" FROM "other" AS "other" NATURAL LEFT JOIN "users" GROUP BY "id"')   }
      its(:to_subquery) { should eql('(SELECT "id", COALESCE (COUNT ("age"), 0) AS "count" FROM "other" AS "other" NATURAL LEFT JOIN "users" GROUP BY "id")') }
    end

    context 'when the operand is a projection' do
      let(:operand)       { base_relation.project([ :id, :name ])                                  }
      let(:summarization) { operand.summarize(summarize_per) { |r| r.add(:count, r[:name].count) } }

      it_should_behave_like 'a generated SQL SELECT query'

      its(:to_s)        { should eql('SELECT "id", COALESCE (COUNT ("name"), 0) AS "count" FROM "other" AS "other" NATURAL LEFT JOIN (SELECT DISTINCT "id", "name" FROM "users") AS "users" GROUP BY "id"')   }
      its(:to_subquery) { should eql('(SELECT "id", COALESCE (COUNT ("name"), 0) AS "count" FROM "other" AS "other" NATURAL LEFT JOIN (SELECT DISTINCT "id", "name" FROM "users") AS "users" GROUP BY "id")') }
    end

    context 'when the operand is an extension' do
      let(:operand) { base_relation.extend { |r| r.add(:one, 1) } }

      it_should_behave_like 'a generated SQL SELECT query'

      its(:to_s)        { should eql('SELECT "id", COALESCE (COUNT ("age"), 0) AS "count" FROM "other" AS "other" NATURAL LEFT JOIN (SELECT *, 1 AS "one" FROM "users") AS "users" GROUP BY "id"')   }
      its(:to_subquery) { should eql('(SELECT "id", COALESCE (COUNT ("age"), 0) AS "count" FROM "other" AS "other" NATURAL LEFT JOIN (SELECT *, 1 AS "one" FROM "users") AS "users" GROUP BY "id")') }
    end

    context 'when the operand is a rename' do
      let(:operand) { base_relation.rename(:name => :other_name) }

      it_should_behave_like 'a generated SQL SELECT query'

      its(:to_s)        { should eql('SELECT "id", COALESCE (COUNT ("age"), 0) AS "count" FROM "other" AS "other" NATURAL LEFT JOIN (SELECT "id", "name" AS "other_name", "age" FROM "users") AS "users" GROUP BY "id"')   }
      its(:to_subquery) { should eql('(SELECT "id", COALESCE (COUNT ("age"), 0) AS "count" FROM "other" AS "other" NATURAL LEFT JOIN (SELECT "id", "name" AS "other_name", "age" FROM "users") AS "users" GROUP BY "id")') }
    end

    context 'when the operand is a restriction' do
      let(:operand) { base_relation.restrict { |r| r[:id].eq(1) } }

      it_should_behave_like 'a generated SQL SELECT query'

      its(:to_s)        { should eql('SELECT "id", COALESCE (COUNT ("age"), 0) AS "count" FROM "other" AS "other" NATURAL LEFT JOIN (SELECT * FROM "users" WHERE "id" = 1) AS "users" GROUP BY "id"')   }
      its(:to_subquery) { should eql('(SELECT "id", COALESCE (COUNT ("age"), 0) AS "count" FROM "other" AS "other" NATURAL LEFT JOIN (SELECT * FROM "users" WHERE "id" = 1) AS "users" GROUP BY "id")') }
    end

    context 'when the operand is ordered' do
      let(:operand) { base_relation.order }

      it_should_behave_like 'a generated SQL SELECT query'

      its(:to_s)        { should eql('SELECT "id", COALESCE (COUNT ("age"), 0) AS "count" FROM "other" AS "other" NATURAL LEFT JOIN (SELECT * FROM "users" ORDER BY "id", "name", "age") AS "users" GROUP BY "id"')   }
      its(:to_subquery) { should eql('(SELECT "id", COALESCE (COUNT ("age"), 0) AS "count" FROM "other" AS "other" NATURAL LEFT JOIN (SELECT * FROM "users" ORDER BY "id", "name", "age") AS "users" GROUP BY "id")') }
    end

    context 'when the operand is reversed' do
      let(:operand) { base_relation.order.reverse }

      it_should_behave_like 'a generated SQL SELECT query'

      its(:to_s)        { should eql('SELECT "id", COALESCE (COUNT ("age"), 0) AS "count" FROM "other" AS "other" NATURAL LEFT JOIN (SELECT * FROM "users" ORDER BY "id" DESC, "name" DESC, "age" DESC) AS "users" GROUP BY "id"')   }
      its(:to_subquery) { should eql('(SELECT "id", COALESCE (COUNT ("age"), 0) AS "count" FROM "other" AS "other" NATURAL LEFT JOIN (SELECT * FROM "users" ORDER BY "id" DESC, "name" DESC, "age" DESC) AS "users" GROUP BY "id")') }
    end

    context 'when the operand is limited' do
      let(:operand) { base_relation.order.take(1) }

      it_should_behave_like 'a generated SQL SELECT query'

      its(:to_s)        { should eql('SELECT "id", COALESCE (COUNT ("age"), 0) AS "count" FROM "other" AS "other" NATURAL LEFT JOIN (SELECT * FROM "users" ORDER BY "id", "name", "age" LIMIT 1) AS "users" GROUP BY "id"')   }
      its(:to_subquery) { should eql('(SELECT "id", COALESCE (COUNT ("age"), 0) AS "count" FROM "other" AS "other" NATURAL LEFT JOIN (SELECT * FROM "users" ORDER BY "id", "name", "age" LIMIT 1) AS "users" GROUP BY "id")') }
    end

    context 'when the operand is an offset' do
      let(:operand) { base_relation.order.drop(1) }

      it_should_behave_like 'a generated SQL SELECT query'

      its(:to_s)        { should eql('SELECT "id", COALESCE (COUNT ("age"), 0) AS "count" FROM "other" AS "other" NATURAL LEFT JOIN (SELECT * FROM "users" ORDER BY "id", "name", "age" OFFSET 1) AS "users" GROUP BY "id"')   }
      its(:to_subquery) { should eql('(SELECT "id", COALESCE (COUNT ("age"), 0) AS "count" FROM "other" AS "other" NATURAL LEFT JOIN (SELECT * FROM "users" ORDER BY "id", "name", "age" OFFSET 1) AS "users" GROUP BY "id")') }
    end

    context 'when the operand is a difference' do
      let(:operand) { base_relation.difference(base_relation) }

      it_should_behave_like 'a generated SQL SELECT query'

      its(:to_s)        { should eql('SELECT "id", COALESCE (COUNT ("age"), 0) AS "count" FROM "other" AS "other" NATURAL LEFT JOIN ((SELECT "id", "name", "age" FROM "users") EXCEPT (SELECT "id", "name", "age" FROM "users")) AS "users" GROUP BY "id"')   }
      its(:to_subquery) { should eql('(SELECT "id", COALESCE (COUNT ("age"), 0) AS "count" FROM "other" AS "other" NATURAL LEFT JOIN ((SELECT "id", "name", "age" FROM "users") EXCEPT (SELECT "id", "name", "age" FROM "users")) AS "users" GROUP BY "id")') }
    end

    context 'when the operand is an intersection' do
      let(:operand) { base_relation.intersect(base_relation) }

      it_should_behave_like 'a generated SQL SELECT query'

      its(:to_s)        { should eql('SELECT "id", COALESCE (COUNT ("age"), 0) AS "count" FROM "other" AS "other" NATURAL LEFT JOIN ((SELECT "id", "name", "age" FROM "users") INTERSECT (SELECT "id", "name", "age" FROM "users")) AS "users" GROUP BY "id"')   }
      its(:to_subquery) { should eql('(SELECT "id", COALESCE (COUNT ("age"), 0) AS "count" FROM "other" AS "other" NATURAL LEFT JOIN ((SELECT "id", "name", "age" FROM "users") INTERSECT (SELECT "id", "name", "age" FROM "users")) AS "users" GROUP BY "id")') }
    end

    context 'when the operand is a union' do
      let(:operand) { base_relation.union(base_relation) }

      it_should_behave_like 'a generated SQL SELECT query'

      its(:to_s)        { should eql('SELECT "id", COALESCE (COUNT ("age"), 0) AS "count" FROM "other" AS "other" NATURAL LEFT JOIN ((SELECT "id", "name", "age" FROM "users") UNION (SELECT "id", "name", "age" FROM "users")) AS "users" GROUP BY "id"')   }
      its(:to_subquery) { should eql('(SELECT "id", COALESCE (COUNT ("age"), 0) AS "count" FROM "other" AS "other" NATURAL LEFT JOIN ((SELECT "id", "name", "age" FROM "users") UNION (SELECT "id", "name", "age" FROM "users")) AS "users" GROUP BY "id")') }
    end

    context 'when the operand is a join' do
      let(:operand) { base_relation.join(base_relation) }

      it_should_behave_like 'a generated SQL SELECT query'

      its(:to_s)        { should eql('SELECT "id", COALESCE (COUNT ("age"), 0) AS "count" FROM "other" AS "other" NATURAL LEFT JOIN (SELECT * FROM "users" AS "left" NATURAL JOIN "users" AS "right") AS "users" GROUP BY "id"')   }
      its(:to_subquery) { should eql('(SELECT "id", COALESCE (COUNT ("age"), 0) AS "count" FROM "other" AS "other" NATURAL LEFT JOIN (SELECT * FROM "users" AS "left" NATURAL JOIN "users" AS "right") AS "users" GROUP BY "id")') }
    end
  end

  context 'summarize per another projected relation' do
    let(:summarize_per) { other_relation.project([ :id ])                                       }
    let(:summarization) { operand.summarize(summarize_per) { |r| r.add(:count, r[:age].count) } }

    context 'when the operand is a base relation' do
      let(:operand) { base_relation }

      it_should_behave_like 'a generated SQL SELECT query'

      its(:to_s)        { should eql('SELECT "id", COALESCE (COUNT ("age"), 0) AS "count" FROM (SELECT DISTINCT "id" FROM "other") AS "other" NATURAL LEFT JOIN "users" GROUP BY "id"')   }
      its(:to_subquery) { should eql('(SELECT "id", COALESCE (COUNT ("age"), 0) AS "count" FROM (SELECT DISTINCT "id" FROM "other") AS "other" NATURAL LEFT JOIN "users" GROUP BY "id")') }
    end

    context 'when the operand is a projection' do
      let(:operand)       { base_relation.project([ :id, :name ])                                  }
      let(:summarization) { operand.summarize(summarize_per) { |r| r.add(:count, r[:name].count) } }

      it_should_behave_like 'a generated SQL SELECT query'

      its(:to_s)        { should eql('SELECT "id", COALESCE (COUNT ("name"), 0) AS "count" FROM (SELECT DISTINCT "id" FROM "other") AS "other" NATURAL LEFT JOIN (SELECT DISTINCT "id", "name" FROM "users") AS "users" GROUP BY "id"')   }
      its(:to_subquery) { should eql('(SELECT "id", COALESCE (COUNT ("name"), 0) AS "count" FROM (SELECT DISTINCT "id" FROM "other") AS "other" NATURAL LEFT JOIN (SELECT DISTINCT "id", "name" FROM "users") AS "users" GROUP BY "id")') }
    end

    context 'when the operand is an extension' do
      let(:operand) { base_relation.extend { |r| r.add(:one, 1) } }

      it_should_behave_like 'a generated SQL SELECT query'

      its(:to_s)        { should eql('SELECT "id", COALESCE (COUNT ("age"), 0) AS "count" FROM (SELECT DISTINCT "id" FROM "other") AS "other" NATURAL LEFT JOIN (SELECT *, 1 AS "one" FROM "users") AS "users" GROUP BY "id"')   }
      its(:to_subquery) { should eql('(SELECT "id", COALESCE (COUNT ("age"), 0) AS "count" FROM (SELECT DISTINCT "id" FROM "other") AS "other" NATURAL LEFT JOIN (SELECT *, 1 AS "one" FROM "users") AS "users" GROUP BY "id")') }
    end

    context 'when the operand is a rename' do
      let(:operand) { base_relation.rename(:name => :other_name) }

      it_should_behave_like 'a generated SQL SELECT query'

      its(:to_s)        { should eql('SELECT "id", COALESCE (COUNT ("age"), 0) AS "count" FROM (SELECT DISTINCT "id" FROM "other") AS "other" NATURAL LEFT JOIN (SELECT "id", "name" AS "other_name", "age" FROM "users") AS "users" GROUP BY "id"')   }
      its(:to_subquery) { should eql('(SELECT "id", COALESCE (COUNT ("age"), 0) AS "count" FROM (SELECT DISTINCT "id" FROM "other") AS "other" NATURAL LEFT JOIN (SELECT "id", "name" AS "other_name", "age" FROM "users") AS "users" GROUP BY "id")') }
    end

    context 'when the operand is a restriction' do
      let(:operand) { base_relation.restrict { |r| r[:id].eq(1) } }

      it_should_behave_like 'a generated SQL SELECT query'

      its(:to_s)        { should eql('SELECT "id", COALESCE (COUNT ("age"), 0) AS "count" FROM (SELECT DISTINCT "id" FROM "other") AS "other" NATURAL LEFT JOIN (SELECT * FROM "users" WHERE "id" = 1) AS "users" GROUP BY "id"')   }
      its(:to_subquery) { should eql('(SELECT "id", COALESCE (COUNT ("age"), 0) AS "count" FROM (SELECT DISTINCT "id" FROM "other") AS "other" NATURAL LEFT JOIN (SELECT * FROM "users" WHERE "id" = 1) AS "users" GROUP BY "id")') }
    end

    context 'when the operand is ordered' do
      let(:operand) { base_relation.order }

      it_should_behave_like 'a generated SQL SELECT query'

      its(:to_s)        { should eql('SELECT "id", COALESCE (COUNT ("age"), 0) AS "count" FROM (SELECT DISTINCT "id" FROM "other") AS "other" NATURAL LEFT JOIN (SELECT * FROM "users" ORDER BY "id", "name", "age") AS "users" GROUP BY "id"')   }
      its(:to_subquery) { should eql('(SELECT "id", COALESCE (COUNT ("age"), 0) AS "count" FROM (SELECT DISTINCT "id" FROM "other") AS "other" NATURAL LEFT JOIN (SELECT * FROM "users" ORDER BY "id", "name", "age") AS "users" GROUP BY "id")') }
    end

    context 'when the operand is reversed' do
      let(:operand) { base_relation.order.reverse }

      it_should_behave_like 'a generated SQL SELECT query'

      its(:to_s)        { should eql('SELECT "id", COALESCE (COUNT ("age"), 0) AS "count" FROM (SELECT DISTINCT "id" FROM "other") AS "other" NATURAL LEFT JOIN (SELECT * FROM "users" ORDER BY "id" DESC, "name" DESC, "age" DESC) AS "users" GROUP BY "id"')   }
      its(:to_subquery) { should eql('(SELECT "id", COALESCE (COUNT ("age"), 0) AS "count" FROM (SELECT DISTINCT "id" FROM "other") AS "other" NATURAL LEFT JOIN (SELECT * FROM "users" ORDER BY "id" DESC, "name" DESC, "age" DESC) AS "users" GROUP BY "id")') }
    end

    context 'when the operand is limited' do
      let(:operand) { base_relation.order.take(1) }

      it_should_behave_like 'a generated SQL SELECT query'

      its(:to_s)        { should eql('SELECT "id", COALESCE (COUNT ("age"), 0) AS "count" FROM (SELECT DISTINCT "id" FROM "other") AS "other" NATURAL LEFT JOIN (SELECT * FROM "users" ORDER BY "id", "name", "age" LIMIT 1) AS "users" GROUP BY "id"')   }
      its(:to_subquery) { should eql('(SELECT "id", COALESCE (COUNT ("age"), 0) AS "count" FROM (SELECT DISTINCT "id" FROM "other") AS "other" NATURAL LEFT JOIN (SELECT * FROM "users" ORDER BY "id", "name", "age" LIMIT 1) AS "users" GROUP BY "id")') }
    end

    context 'when the operand is an offset' do
      let(:operand) { base_relation.order.drop(1) }

      it_should_behave_like 'a generated SQL SELECT query'

      its(:to_s)        { should eql('SELECT "id", COALESCE (COUNT ("age"), 0) AS "count" FROM (SELECT DISTINCT "id" FROM "other") AS "other" NATURAL LEFT JOIN (SELECT * FROM "users" ORDER BY "id", "name", "age" OFFSET 1) AS "users" GROUP BY "id"')   }
      its(:to_subquery) { should eql('(SELECT "id", COALESCE (COUNT ("age"), 0) AS "count" FROM (SELECT DISTINCT "id" FROM "other") AS "other" NATURAL LEFT JOIN (SELECT * FROM "users" ORDER BY "id", "name", "age" OFFSET 1) AS "users" GROUP BY "id")') }
    end

    context 'when the operand is a difference' do
      let(:operand) { base_relation.difference(base_relation) }

      it_should_behave_like 'a generated SQL SELECT query'

      its(:to_s)        { should eql('SELECT "id", COALESCE (COUNT ("age"), 0) AS "count" FROM (SELECT DISTINCT "id" FROM "other") AS "other" NATURAL LEFT JOIN ((SELECT "id", "name", "age" FROM "users") EXCEPT (SELECT "id", "name", "age" FROM "users")) AS "users" GROUP BY "id"')   }
      its(:to_subquery) { should eql('(SELECT "id", COALESCE (COUNT ("age"), 0) AS "count" FROM (SELECT DISTINCT "id" FROM "other") AS "other" NATURAL LEFT JOIN ((SELECT "id", "name", "age" FROM "users") EXCEPT (SELECT "id", "name", "age" FROM "users")) AS "users" GROUP BY "id")') }
    end

    context 'when the operand is an intersection' do
      let(:operand) { base_relation.intersect(base_relation) }

      it_should_behave_like 'a generated SQL SELECT query'

      its(:to_s)        { should eql('SELECT "id", COALESCE (COUNT ("age"), 0) AS "count" FROM (SELECT DISTINCT "id" FROM "other") AS "other" NATURAL LEFT JOIN ((SELECT "id", "name", "age" FROM "users") INTERSECT (SELECT "id", "name", "age" FROM "users")) AS "users" GROUP BY "id"')   }
      its(:to_subquery) { should eql('(SELECT "id", COALESCE (COUNT ("age"), 0) AS "count" FROM (SELECT DISTINCT "id" FROM "other") AS "other" NATURAL LEFT JOIN ((SELECT "id", "name", "age" FROM "users") INTERSECT (SELECT "id", "name", "age" FROM "users")) AS "users" GROUP BY "id")') }
    end

    context 'when the operand is a union' do
      let(:operand) { base_relation.union(base_relation) }

      it_should_behave_like 'a generated SQL SELECT query'

      its(:to_s)        { should eql('SELECT "id", COALESCE (COUNT ("age"), 0) AS "count" FROM (SELECT DISTINCT "id" FROM "other") AS "other" NATURAL LEFT JOIN ((SELECT "id", "name", "age" FROM "users") UNION (SELECT "id", "name", "age" FROM "users")) AS "users" GROUP BY "id"')   }
      its(:to_subquery) { should eql('(SELECT "id", COALESCE (COUNT ("age"), 0) AS "count" FROM (SELECT DISTINCT "id" FROM "other") AS "other" NATURAL LEFT JOIN ((SELECT "id", "name", "age" FROM "users") UNION (SELECT "id", "name", "age" FROM "users")) AS "users" GROUP BY "id")') }
    end

    context 'when the operand is a join' do
      let(:operand) { base_relation.join(base_relation) }

      it_should_behave_like 'a generated SQL SELECT query'

      its(:to_s)        { should eql('SELECT "id", COALESCE (COUNT ("age"), 0) AS "count" FROM (SELECT DISTINCT "id" FROM "other") AS "other" NATURAL LEFT JOIN (SELECT * FROM "users" AS "left" NATURAL JOIN "users" AS "right") AS "users" GROUP BY "id"')   }
      its(:to_subquery) { should eql('(SELECT "id", COALESCE (COUNT ("age"), 0) AS "count" FROM (SELECT DISTINCT "id" FROM "other") AS "other" NATURAL LEFT JOIN (SELECT * FROM "users" AS "left" NATURAL JOIN "users" AS "right") AS "users" GROUP BY "id")') }
    end
  end
end
