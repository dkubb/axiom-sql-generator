# encoding: utf-8

require 'spec_helper'

describe SQL::Generator::Relation::Unary, '#visit_veritas_relation_operation_order' do
  subject { object.visit_veritas_relation_operation_order(order) }

  let(:relation_name) { 'users'                                          }
  let(:id)            { Attribute::Integer.new(:id)                      }
  let(:name)          { Attribute::String.new(:name)                     }
  let(:age)           { Attribute::Integer.new(:age, :required => false) }
  let(:header)        { [ id, name, age ]                                }
  let(:body)          { [ [ 1, 'Dan Kubb', 35 ] ].each                   }
  let(:base_relation) { Relation::Base.new(relation_name, header, body)  }
  let(:order)         { operand.order                                    }
  let(:object)        { described_class.new                              }

  context 'when the operand is a base relation' do
    let(:operand) { base_relation }

    it_should_behave_like 'a generated SQL SELECT query'

    its(:to_s)        { should eql('SELECT "id", "name", "age" FROM "users" ORDER BY "id", "name", "age"') }
    its(:to_subquery) { should eql('(SELECT * FROM "users" ORDER BY "id", "name", "age")')                 }
  end

  context 'when the operand is a projection' do
    context 'when the projection contains the base_relation' do
      let(:operand) { base_relation.project([ :id, :name ]) }

      it_should_behave_like 'a generated SQL SELECT query'

      its(:to_s)        { should eql('SELECT DISTINCT "id", "name" FROM "users" ORDER BY "id", "name"')   }
      its(:to_subquery) { should eql('(SELECT DISTINCT "id", "name" FROM "users" ORDER BY "id", "name")') }
    end

    context 'when the projection contains an order' do
      let(:operand) { base_relation.order.project([ :id, :name ]) }

      it_should_behave_like 'a generated SQL SELECT query'

      its(:to_s)        { should eql('SELECT DISTINCT "id", "name" FROM (SELECT * FROM "users" ORDER BY "id", "name", "age") AS "users" ORDER BY "id", "name"')   }
      its(:to_subquery) { should eql('(SELECT DISTINCT "id", "name" FROM (SELECT * FROM "users" ORDER BY "id", "name", "age") AS "users" ORDER BY "id", "name")') }
    end
  end

  context 'when the operand is an extension' do
    let(:operand) { base_relation.extend { |r| r.add(:one, 1) }.order }

    it_should_behave_like 'a generated SQL SELECT query'

    its(:to_s)        { should eql('SELECT "id", "name", "age", 1 AS "one" FROM "users" ORDER BY "id", "name", "age", "one"') }
    its(:to_subquery) { should eql('(SELECT *, 1 AS "one" FROM "users" ORDER BY "id", "name", "age", "one")')                 }
  end

  context 'when the operand is a rename' do
    let(:operand) { base_relation.rename(:id => :user_id) }

    it_should_behave_like 'a generated SQL SELECT query'

    its(:to_s)        { should eql('SELECT "id" AS "user_id", "name", "age" FROM "users" ORDER BY "user_id", "name", "age"')   }
    its(:to_subquery) { should eql('(SELECT "id" AS "user_id", "name", "age" FROM "users" ORDER BY "user_id", "name", "age")') }
  end

  context 'when the operand is a restriction' do
    let(:operand) { base_relation.restrict { |r| r[:id].eq(1) } }

    it_should_behave_like 'a generated SQL SELECT query'

    its(:to_s)        { should eql('SELECT "id", "name", "age" FROM "users" WHERE "id" = 1 ORDER BY "id", "name", "age"') }
    its(:to_subquery) { should eql('(SELECT * FROM "users" WHERE "id" = 1 ORDER BY "id", "name", "age")')                 }
  end

  context 'when the operand is a summarization' do
    context 'summarize per table dee' do
      let(:summarize_per) { TABLE_DEE                                                                        }
      let(:operand)       { base_relation.summarize(summarize_per) { |r| r.add(:count, r[:id].count) }.order }

      it_should_behave_like 'a generated SQL SELECT query'

      its(:to_s)        { should eql('SELECT COALESCE (COUNT ("id"), 0) AS "count" FROM "users" ORDER BY "count"')   }
      its(:to_subquery) { should eql('(SELECT COALESCE (COUNT ("id"), 0) AS "count" FROM "users" ORDER BY "count")') }
    end

    context 'summarize per table dum' do
      let(:summarize_per) { TABLE_DUM                                                                        }
      let(:operand)       { base_relation.summarize(summarize_per) { |r| r.add(:count, r[:id].count) }.order }

      it_should_behave_like 'a generated SQL SELECT query'

      its(:to_s)        { should eql('SELECT COALESCE (COUNT ("id"), 0) AS "count" FROM "users" HAVING 1 = 0 ORDER BY "count"')   }
      its(:to_subquery) { should eql('(SELECT COALESCE (COUNT ("id"), 0) AS "count" FROM "users" HAVING 1 = 0 ORDER BY "count")') }
    end

    context 'summarize by a subset of the operand header' do
      let(:operand) { base_relation.summarize([ :id, :name ]) { |r| r.add(:count, r[:age].count) }.order }

      it_should_behave_like 'a generated SQL SELECT query'

      its(:to_s)        { should eql('SELECT "id", "name", COALESCE (COUNT ("age"), 0) AS "count" FROM "users" GROUP BY "id", "name" HAVING COUNT (*) > 0 ORDER BY "id", "name", "count"')   }
      its(:to_subquery) { should eql('(SELECT "id", "name", COALESCE (COUNT ("age"), 0) AS "count" FROM "users" GROUP BY "id", "name" HAVING COUNT (*) > 0 ORDER BY "id", "name", "count")') }
    end
  end

  context 'when the operand is ordered' do
    let(:operand) { base_relation.order }

    it_should_behave_like 'a generated SQL SELECT query'

    its(:to_s)        { should eql('SELECT "id", "name", "age" FROM "users" ORDER BY "id", "name", "age"') }
    its(:to_subquery) { should eql('(SELECT * FROM "users" ORDER BY "id", "name", "age")')                 }
  end

  context 'when the operand is reversed' do
    let(:operand) { base_relation.order.reverse }

    it_should_behave_like 'a generated SQL SELECT query'

    its(:to_s)        { should eql('SELECT "id", "name", "age" FROM "users" ORDER BY "id", "name", "age"') }
    its(:to_subquery) { should eql('(SELECT * FROM "users" ORDER BY "id", "name", "age")')                 }
  end

  context 'when the operand is limited' do
    let(:operand) { base_relation.order { [ id.desc, name.desc, age.desc ] }.take(1) }

    it_should_behave_like 'a generated SQL SELECT query'

    its(:to_s)        { should eql('SELECT "id", "name", "age" FROM (SELECT * FROM "users" ORDER BY "id" DESC, "name" DESC, "age" DESC LIMIT 1) AS "users" ORDER BY "id", "name", "age"') }
    its(:to_subquery) { should eql('(SELECT * FROM (SELECT * FROM "users" ORDER BY "id" DESC, "name" DESC, "age" DESC LIMIT 1) AS "users" ORDER BY "id", "name", "age")')                 }
  end

  context 'when the operand is an offset' do
    let(:operand) { base_relation.order { [ id.desc, name.desc, age.desc ] }.drop(1) }

    it_should_behave_like 'a generated SQL SELECT query'

    its(:to_s)        { should eql('SELECT "id", "name", "age" FROM (SELECT * FROM "users" ORDER BY "id" DESC, "name" DESC, "age" DESC OFFSET 1) AS "users" ORDER BY "id", "name", "age"') }
    its(:to_subquery) { should eql('(SELECT * FROM (SELECT * FROM "users" ORDER BY "id" DESC, "name" DESC, "age" DESC OFFSET 1) AS "users" ORDER BY "id", "name", "age")')                 }
  end

  context 'when the operand is a difference' do
    let(:operand) { base_relation.difference(base_relation) }

    it_should_behave_like 'a generated SQL SELECT query'

    its(:to_s)        { should eql('SELECT "id", "name", "age" FROM ((SELECT "id", "name", "age" FROM "users") EXCEPT (SELECT "id", "name", "age" FROM "users")) AS "users" ORDER BY "id", "name", "age"') }
    its(:to_subquery) { should eql('(SELECT * FROM ((SELECT "id", "name", "age" FROM "users") EXCEPT (SELECT "id", "name", "age" FROM "users")) AS "users" ORDER BY "id", "name", "age")')                 }
  end

  context 'when the operand is an intersection' do
    let(:operand) { base_relation.intersect(base_relation) }

    it_should_behave_like 'a generated SQL SELECT query'

    its(:to_s)        { should eql('SELECT "id", "name", "age" FROM ((SELECT "id", "name", "age" FROM "users") INTERSECT (SELECT "id", "name", "age" FROM "users")) AS "users" ORDER BY "id", "name", "age"') }
    its(:to_subquery) { should eql('(SELECT * FROM ((SELECT "id", "name", "age" FROM "users") INTERSECT (SELECT "id", "name", "age" FROM "users")) AS "users" ORDER BY "id", "name", "age")')                 }
  end

  context 'when the operand is a union' do
    let(:operand) { base_relation.union(base_relation) }

    it_should_behave_like 'a generated SQL SELECT query'

    its(:to_s)        { should eql('SELECT "id", "name", "age" FROM ((SELECT "id", "name", "age" FROM "users") UNION (SELECT "id", "name", "age" FROM "users")) AS "users" ORDER BY "id", "name", "age"') }
    its(:to_subquery) { should eql('(SELECT * FROM ((SELECT "id", "name", "age" FROM "users") UNION (SELECT "id", "name", "age" FROM "users")) AS "users" ORDER BY "id", "name", "age")')                 }
  end

  context 'when the operand is a join' do
    let(:operand) { base_relation.join(base_relation) }

    it_should_behave_like 'a generated SQL SELECT query'

    its(:to_s)        { should eql('SELECT "id", "name", "age" FROM (SELECT * FROM "users" AS "left" NATURAL JOIN "users" AS "right") AS "users" ORDER BY "id", "name", "age"') }
    its(:to_subquery) { should eql('(SELECT * FROM (SELECT * FROM "users" AS "left" NATURAL JOIN "users" AS "right") AS "users" ORDER BY "id", "name", "age")')                 }
  end
end
