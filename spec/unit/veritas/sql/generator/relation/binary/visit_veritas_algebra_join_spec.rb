# encoding: utf-8

require 'spec_helper'

describe SQL::Generator::Relation::Binary, '#visit_veritas_algebra_join' do
  subject { object.visit_veritas_algebra_join(join) }

  let(:relation_name)  { 'users'                                          }
  let(:id)             { Attribute::Integer.new(:id)                      }
  let(:name)           { Attribute::String.new(:name)                     }
  let(:age)            { Attribute::Integer.new(:age, :required => false) }
  let(:header)         { [ id, name, age ]                                }
  let(:body)           { [ [ 1, 'Dan Kubb', 35 ] ].each                   }
  let(:base_relation)  { Relation::Base.new(relation_name, header, body)  }
  let(:other_relation) { Relation::Base.new('other', header, body)        }
  let(:left)           { operand                                          }
  let(:right)          { operand                                          }
  let(:join)           { left.join(right)                                 }
  let(:object)         { described_class.new                              }

  context 'when the operands are base relations' do
    let(:operand) { base_relation }

    it_should_behave_like 'a generated SQL SELECT query'

    its(:to_s)        { should eql('SELECT "id", "name", "age" FROM "users" AS "left" NATURAL JOIN "users" AS "right"') }
    its(:to_subquery) { should eql('(SELECT * FROM "users" AS "left" NATURAL JOIN "users" AS "right")')                 }
  end

  context 'when the operands are projections' do
    let(:operand) { base_relation.project([ :id, :name ]) }

    it_should_behave_like 'a generated SQL SELECT query'

    its(:to_s)        { should eql('SELECT "id", "name" FROM (SELECT DISTINCT "id", "name" FROM "users") AS "left" NATURAL JOIN (SELECT DISTINCT "id", "name" FROM "users") AS "right"') }
    its(:to_subquery) { should eql('(SELECT * FROM (SELECT DISTINCT "id", "name" FROM "users") AS "left" NATURAL JOIN (SELECT DISTINCT "id", "name" FROM "users") AS "right")')          }
  end

  context 'when the operand is an extension' do
    let(:operand) { base_relation.extend { |r| r.add(:one, 1) } }

    it_should_behave_like 'a generated SQL SELECT query'

    its(:to_s)        { should eql('SELECT "id", "name", "age", "one" FROM (SELECT *, 1 AS "one" FROM "users") AS "left" NATURAL JOIN (SELECT *, 1 AS "one" FROM "users") AS "right"') }
    its(:to_subquery) { should eql('(SELECT * FROM (SELECT *, 1 AS "one" FROM "users") AS "left" NATURAL JOIN (SELECT *, 1 AS "one" FROM "users") AS "right")')                        }
  end

  context 'when the operands are rename' do
    let(:operand) { base_relation.rename(:id => :user_id) }

    it_should_behave_like 'a generated SQL SELECT query'

    its(:to_s)        { should eql('SELECT "user_id", "name", "age" FROM (SELECT "id" AS "user_id", "name", "age" FROM "users") AS "left" NATURAL JOIN (SELECT "id" AS "user_id", "name", "age" FROM "users") AS "right"') }
    its(:to_subquery) { should eql('(SELECT * FROM (SELECT "id" AS "user_id", "name", "age" FROM "users") AS "left" NATURAL JOIN (SELECT "id" AS "user_id", "name", "age" FROM "users") AS "right")')                      }
  end

  context 'when the operands are restrictions' do
    let(:operand) { base_relation.restrict { |r| r[:id].eq(1) } }

    it_should_behave_like 'a generated SQL SELECT query'

    its(:to_s)        { should eql('SELECT "id", "name", "age" FROM (SELECT * FROM "users" WHERE "id" = 1) AS "left" NATURAL JOIN (SELECT * FROM "users" WHERE "id" = 1) AS "right"') }
    its(:to_subquery) { should eql('(SELECT * FROM (SELECT * FROM "users" WHERE "id" = 1) AS "left" NATURAL JOIN (SELECT * FROM "users" WHERE "id" = 1) AS "right")')                 }
  end

  context 'when the operand is a summarization' do
    context 'summarize per table dee' do
      let(:summarize_per) { TABLE_DEE                                                                  }
      let(:operand)       { base_relation.summarize(summarize_per) { |r| r.add(:count, r[:id].count) } }

      it_should_behave_like 'a generated SQL SELECT query'

      its(:to_s)        { should eql('SELECT "count" FROM (SELECT COALESCE (COUNT ("id"), 0) AS "count" FROM "users") AS "left" NATURAL JOIN (SELECT COALESCE (COUNT ("id"), 0) AS "count" FROM "users") AS "right"') }
      its(:to_subquery) { should eql('(SELECT * FROM (SELECT COALESCE (COUNT ("id"), 0) AS "count" FROM "users") AS "left" NATURAL JOIN (SELECT COALESCE (COUNT ("id"), 0) AS "count" FROM "users") AS "right")')     }
    end

    context 'summarize per table dum' do
      let(:summarize_per) { TABLE_DUM                                                                  }
      let(:operand)       { base_relation.summarize(summarize_per) { |r| r.add(:count, r[:id].count) } }

      it_should_behave_like 'a generated SQL SELECT query'

      its(:to_s)        { should eql('SELECT "count" FROM (SELECT COALESCE (COUNT ("id"), 0) AS "count" FROM "users" HAVING 1 = 0) AS "left" NATURAL JOIN (SELECT COALESCE (COUNT ("id"), 0) AS "count" FROM "users" HAVING 1 = 0) AS "right"') }
      its(:to_subquery) { should eql('(SELECT * FROM (SELECT COALESCE (COUNT ("id"), 0) AS "count" FROM "users" HAVING 1 = 0) AS "left" NATURAL JOIN (SELECT COALESCE (COUNT ("id"), 0) AS "count" FROM "users" HAVING 1 = 0) AS "right")')     }
    end

    context 'summarize by a subset of the operand header' do
      let(:operand) { base_relation.summarize([ :id, :name ]) { |r| r.add(:count, r[:age].count) } }

      it_should_behave_like 'a generated SQL SELECT query'

      its(:to_s)        { should eql('SELECT "id", "name", "count" FROM (SELECT "id", "name", COALESCE (COUNT ("age"), 0) AS "count" FROM "users" GROUP BY "id", "name" HAVING COUNT (*) > 0) AS "left" NATURAL JOIN (SELECT "id", "name", COALESCE (COUNT ("age"), 0) AS "count" FROM "users" GROUP BY "id", "name" HAVING COUNT (*) > 0) AS "right"') }
      its(:to_subquery) { should eql('(SELECT * FROM (SELECT "id", "name", COALESCE (COUNT ("age"), 0) AS "count" FROM "users" GROUP BY "id", "name" HAVING COUNT (*) > 0) AS "left" NATURAL JOIN (SELECT "id", "name", COALESCE (COUNT ("age"), 0) AS "count" FROM "users" GROUP BY "id", "name" HAVING COUNT (*) > 0) AS "right")')                   }
    end
  end

  context 'when the operands are ordered' do
    let(:operand) { base_relation.order }

    it_should_behave_like 'a generated SQL SELECT query'

    its(:to_s)        { should eql('SELECT "id", "name", "age" FROM (SELECT * FROM "users" ORDER BY "id", "name", "age") AS "left" NATURAL JOIN (SELECT * FROM "users" ORDER BY "id", "name", "age") AS "right"') }
    its(:to_subquery) { should eql('(SELECT * FROM (SELECT * FROM "users" ORDER BY "id", "name", "age") AS "left" NATURAL JOIN (SELECT * FROM "users" ORDER BY "id", "name", "age") AS "right")')                 }
  end

  context 'when the operands are reversed' do
    let(:operand) { base_relation.order.reverse }

    it_should_behave_like 'a generated SQL SELECT query'

    its(:to_s)        { should eql('SELECT "id", "name", "age" FROM (SELECT * FROM "users" ORDER BY "id" DESC, "name" DESC, "age" DESC) AS "left" NATURAL JOIN (SELECT * FROM "users" ORDER BY "id" DESC, "name" DESC, "age" DESC) AS "right"') }
    its(:to_subquery) { should eql('(SELECT * FROM (SELECT * FROM "users" ORDER BY "id" DESC, "name" DESC, "age" DESC) AS "left" NATURAL JOIN (SELECT * FROM "users" ORDER BY "id" DESC, "name" DESC, "age" DESC) AS "right")')                 }
  end

  context 'when the operands are limited' do
    let(:operand) { base_relation.order.take(1) }

    it_should_behave_like 'a generated SQL SELECT query'

    its(:to_s)        { should eql('SELECT "id", "name", "age" FROM (SELECT * FROM "users" ORDER BY "id", "name", "age" LIMIT 1) AS "left" NATURAL JOIN (SELECT * FROM "users" ORDER BY "id", "name", "age" LIMIT 1) AS "right"') }
    its(:to_subquery) { should eql('(SELECT * FROM (SELECT * FROM "users" ORDER BY "id", "name", "age" LIMIT 1) AS "left" NATURAL JOIN (SELECT * FROM "users" ORDER BY "id", "name", "age" LIMIT 1) AS "right")')                 }
  end

  context 'when the operands are offsets' do
    let(:operand) { base_relation.order.drop(1) }

    it_should_behave_like 'a generated SQL SELECT query'

    its(:to_s)        { should eql('SELECT "id", "name", "age" FROM (SELECT * FROM "users" ORDER BY "id", "name", "age" OFFSET 1) AS "left" NATURAL JOIN (SELECT * FROM "users" ORDER BY "id", "name", "age" OFFSET 1) AS "right"') }
    its(:to_subquery) { should eql('(SELECT * FROM (SELECT * FROM "users" ORDER BY "id", "name", "age" OFFSET 1) AS "left" NATURAL JOIN (SELECT * FROM "users" ORDER BY "id", "name", "age" OFFSET 1) AS "right")')                 }
  end

  context 'when the operands are differences' do
    let(:operand) { base_relation.difference(base_relation) }

    it_should_behave_like 'a generated SQL SELECT query'

    its(:to_s)        { should eql('SELECT "id", "name", "age" FROM ((SELECT "id", "name", "age" FROM "users") EXCEPT (SELECT "id", "name", "age" FROM "users")) AS "left" NATURAL JOIN ((SELECT "id", "name", "age" FROM "users") EXCEPT (SELECT "id", "name", "age" FROM "users")) AS "right"') }
    its(:to_subquery) { should eql('(SELECT * FROM ((SELECT "id", "name", "age" FROM "users") EXCEPT (SELECT "id", "name", "age" FROM "users")) AS "left" NATURAL JOIN ((SELECT "id", "name", "age" FROM "users") EXCEPT (SELECT "id", "name", "age" FROM "users")) AS "right")')                 }
  end

  context 'when the operands are intersections' do
    let(:operand) { base_relation.intersect(base_relation) }

    it_should_behave_like 'a generated SQL SELECT query'

    its(:to_s)        { should eql('SELECT "id", "name", "age" FROM ((SELECT "id", "name", "age" FROM "users") INTERSECT (SELECT "id", "name", "age" FROM "users")) AS "left" NATURAL JOIN ((SELECT "id", "name", "age" FROM "users") INTERSECT (SELECT "id", "name", "age" FROM "users")) AS "right"') }
    its(:to_subquery) { should eql('(SELECT * FROM ((SELECT "id", "name", "age" FROM "users") INTERSECT (SELECT "id", "name", "age" FROM "users")) AS "left" NATURAL JOIN ((SELECT "id", "name", "age" FROM "users") INTERSECT (SELECT "id", "name", "age" FROM "users")) AS "right")')                 }
  end

  context 'when the operands are unions' do
    let(:operand) { base_relation.union(base_relation) }

    it_should_behave_like 'a generated SQL SELECT query'

    its(:to_s)        { should eql('SELECT "id", "name", "age" FROM ((SELECT "id", "name", "age" FROM "users") UNION (SELECT "id", "name", "age" FROM "users")) AS "left" NATURAL JOIN ((SELECT "id", "name", "age" FROM "users") UNION (SELECT "id", "name", "age" FROM "users")) AS "right"') }
    its(:to_subquery) { should eql('(SELECT * FROM ((SELECT "id", "name", "age" FROM "users") UNION (SELECT "id", "name", "age" FROM "users")) AS "left" NATURAL JOIN ((SELECT "id", "name", "age" FROM "users") UNION (SELECT "id", "name", "age" FROM "users")) AS "right")')                 }
  end

  context 'when the operands are joins' do
    let(:operand) { base_relation.join(base_relation) }

    it_should_behave_like 'a generated SQL SELECT query'

    its(:to_s)        { should eql('SELECT "id", "name", "age" FROM (SELECT * FROM "users" AS "left" NATURAL JOIN "users" AS "right") AS "left" NATURAL JOIN (SELECT * FROM "users" AS "left" NATURAL JOIN "users" AS "right") AS "right"') }
    its(:to_subquery) { should eql('(SELECT * FROM (SELECT * FROM "users" AS "left" NATURAL JOIN "users" AS "right") AS "left" NATURAL JOIN (SELECT * FROM "users" AS "left" NATURAL JOIN "users" AS "right") AS "right")')                 }
  end

  context 'when the operands have different base relations' do
    let(:relation_name) { 'users_others'                             }
    let(:left)          { Relation::Base.new('users',  header, body) }
    let(:right)         { Relation::Base.new('others', header, body) }

    it_should_behave_like 'a generated SQL SELECT query'

    its(:to_s)        { should eql('SELECT "id", "name", "age" FROM "users" AS "left" NATURAL JOIN "others" AS "right"') }
    its(:to_subquery) { should eql('(SELECT * FROM "users" AS "left" NATURAL JOIN "others" AS "right")')                 }
  end
end
