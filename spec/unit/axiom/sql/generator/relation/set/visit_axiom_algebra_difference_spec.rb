# encoding: utf-8

require 'spec_helper'

describe SQL::Generator::Relation::Set, '#visit_axiom_algebra_difference' do
  subject { object.visit_axiom_algebra_difference(difference) }

  let(:relation_name) { 'users'                                         }
  let(:id)            { Attribute::Integer.new(:id)                     }
  let(:name)          { Attribute::String.new(:name)                    }
  let(:age)           { Attribute::Integer.new(:age, required: false)   }
  let(:header)        { [id, name, age]                                 }
  let(:body)          { [[1, 'Dan Kubb', 35]].each                      }
  let(:base_relation) { Relation::Base.new(relation_name, header, body) }
  let(:left)          { operand                                         }
  let(:right)         { operand                                         }
  let(:difference)    { left.difference(right)                          }
  let(:object)        { described_class.new                             }

  context 'when the operands are base relations' do
    let(:operand) { base_relation }

    it_should_behave_like 'a generated SQL SELECT query'

    its(:to_s)        { should eql('(SELECT "id", "name", "age" FROM "users") EXCEPT (SELECT "id", "name", "age" FROM "users")')   }
    its(:to_subquery) { should eql('((SELECT "id", "name", "age" FROM "users") EXCEPT (SELECT "id", "name", "age" FROM "users"))') }
  end

  context 'when the operands are projections' do
    let(:operand) { base_relation.project([:id, :name]) }

    it_should_behave_like 'a generated SQL SELECT query'

    its(:to_s)        { should eql('(SELECT DISTINCT "id", "name" FROM "users") EXCEPT (SELECT DISTINCT "id", "name" FROM "users")')   }
    its(:to_subquery) { should eql('((SELECT DISTINCT "id", "name" FROM "users") EXCEPT (SELECT DISTINCT "id", "name" FROM "users"))') }
  end

  context 'when the operand is an extension' do
    let(:operand) { base_relation.extend { |r| r.add(:one, 1) } }

    it_should_behave_like 'a generated SQL SELECT query'

    its(:to_s)        { should eql('(SELECT "id", "name", "age", 1 AS "one" FROM "users") EXCEPT (SELECT "id", "name", "age", 1 AS "one" FROM "users")')   }
    its(:to_subquery) { should eql('((SELECT "id", "name", "age", 1 AS "one" FROM "users") EXCEPT (SELECT "id", "name", "age", 1 AS "one" FROM "users"))') }
  end

  context 'when the operands are renames' do
    let(:operand) { base_relation.rename(id: :user_id) }

    it_should_behave_like 'a generated SQL SELECT query'

    its(:to_s)        { should eql('(SELECT "id" AS "user_id", "name", "age" FROM "users") EXCEPT (SELECT "id" AS "user_id", "name", "age" FROM "users")')   }
    its(:to_subquery) { should eql('((SELECT "id" AS "user_id", "name", "age" FROM "users") EXCEPT (SELECT "id" AS "user_id", "name", "age" FROM "users"))') }
  end

  context 'when the operands are restrictions' do
    let(:operand) { base_relation.restrict { |r| r.id.eq(1) } }

    it_should_behave_like 'a generated SQL SELECT query'

    its(:to_s)        { should eql('(SELECT "id", "name", "age" FROM "users" WHERE "id" = 1) EXCEPT (SELECT "id", "name", "age" FROM "users" WHERE "id" = 1)')   }
    its(:to_subquery) { should eql('((SELECT "id", "name", "age" FROM "users" WHERE "id" = 1) EXCEPT (SELECT "id", "name", "age" FROM "users" WHERE "id" = 1))') }
  end

  context 'when the operand is a summarization' do
  end

  context 'when the operand is a summarization' do
    context 'summarize per table dee' do
      let(:summarize_per) { TABLE_DEE                                                                }
      let(:operand)       { base_relation.summarize(summarize_per) { |r| r.add(:count, r.id.count) } }

      it_should_behave_like 'a generated SQL SELECT query'

      its(:to_s)        { should eql('(SELECT COUNT ("id") AS "count" FROM "users") EXCEPT (SELECT COUNT ("id") AS "count" FROM "users")')   }
      its(:to_subquery) { should eql('((SELECT COUNT ("id") AS "count" FROM "users") EXCEPT (SELECT COUNT ("id") AS "count" FROM "users"))') }
    end

    context 'summarize per table dum' do
      let(:summarize_per) { TABLE_DUM                                                                }
      let(:operand)       { base_relation.summarize(summarize_per) { |r| r.add(:count, r.id.count) } }

      it_should_behave_like 'a generated SQL SELECT query'

      its(:to_s)        { should eql('(SELECT COUNT ("id") AS "count" FROM "users" HAVING FALSE) EXCEPT (SELECT COUNT ("id") AS "count" FROM "users" HAVING FALSE)')   }
      its(:to_subquery) { should eql('((SELECT COUNT ("id") AS "count" FROM "users" HAVING FALSE) EXCEPT (SELECT COUNT ("id") AS "count" FROM "users" HAVING FALSE))') }
    end

    context 'summarize by a subset of the operand header' do
      let(:operand) { base_relation.summarize([:id, :name]) { |r| r.add(:count, r.age.count) } }

      it_should_behave_like 'a generated SQL SELECT query'

      its(:to_s)        { should eql('(SELECT "id", "name", COUNT ("age") AS "count" FROM "users" GROUP BY "id", "name" HAVING COUNT (*) > 0) EXCEPT (SELECT "id", "name", COUNT ("age") AS "count" FROM "users" GROUP BY "id", "name" HAVING COUNT (*) > 0)')   }
      its(:to_subquery) { should eql('((SELECT "id", "name", COUNT ("age") AS "count" FROM "users" GROUP BY "id", "name" HAVING COUNT (*) > 0) EXCEPT (SELECT "id", "name", COUNT ("age") AS "count" FROM "users" GROUP BY "id", "name" HAVING COUNT (*) > 0))') }
    end
  end

  context 'when the operand is ordered' do
    let(:operand) { base_relation.sort_by { |r| [r.id, r.name, r.age] } }

    it_should_behave_like 'a generated SQL SELECT query'

    its(:to_s)        { should eql('(SELECT "id", "name", "age" FROM "users" ORDER BY "id", "name", "age") EXCEPT (SELECT "id", "name", "age" FROM "users" ORDER BY "id", "name", "age")')   }
    its(:to_subquery) { should eql('((SELECT "id", "name", "age" FROM "users" ORDER BY "id", "name", "age") EXCEPT (SELECT "id", "name", "age" FROM "users" ORDER BY "id", "name", "age"))') }
  end

  context 'when the operand is reversed' do
    let(:operand) { base_relation.sort_by { |r| [r.id, r.name, r.age] }.reverse }

    it_should_behave_like 'a generated SQL SELECT query'

    its(:to_s)        { should eql('(SELECT "id", "name", "age" FROM "users" ORDER BY "id" DESC, "name" DESC, "age" DESC) EXCEPT (SELECT "id", "name", "age" FROM "users" ORDER BY "id" DESC, "name" DESC, "age" DESC)')   }
    its(:to_subquery) { should eql('((SELECT "id", "name", "age" FROM "users" ORDER BY "id" DESC, "name" DESC, "age" DESC) EXCEPT (SELECT "id", "name", "age" FROM "users" ORDER BY "id" DESC, "name" DESC, "age" DESC))') }
  end

  context 'when the operand is limited' do
    let(:operand) { base_relation.sort_by { |r| [r.id, r.name, r.age] }.take(1) }

    it_should_behave_like 'a generated SQL SELECT query'

    its(:to_s)        { should eql('(SELECT "id", "name", "age" FROM "users" ORDER BY "id", "name", "age" LIMIT 1) EXCEPT (SELECT "id", "name", "age" FROM "users" ORDER BY "id", "name", "age" LIMIT 1)')   }
    its(:to_subquery) { should eql('((SELECT "id", "name", "age" FROM "users" ORDER BY "id", "name", "age" LIMIT 1) EXCEPT (SELECT "id", "name", "age" FROM "users" ORDER BY "id", "name", "age" LIMIT 1))') }
  end

  context 'when the operands are offsets' do
    let(:operand) { base_relation.sort_by { |r| [r.id, r.name, r.age] }.drop(1) }

    it_should_behave_like 'a generated SQL SELECT query'

    its(:to_s)        { should eql('(SELECT "id", "name", "age" FROM "users" ORDER BY "id", "name", "age" OFFSET 1) EXCEPT (SELECT "id", "name", "age" FROM "users" ORDER BY "id", "name", "age" OFFSET 1)')   }
    its(:to_subquery) { should eql('((SELECT "id", "name", "age" FROM "users" ORDER BY "id", "name", "age" OFFSET 1) EXCEPT (SELECT "id", "name", "age" FROM "users" ORDER BY "id", "name", "age" OFFSET 1))') }
  end

  context 'when the operands are differences' do
    let(:operand) { base_relation.difference(base_relation) }

    it_should_behave_like 'a generated SQL SELECT query'

    its(:to_s)        { should eql('((SELECT "id", "name", "age" FROM "users") EXCEPT (SELECT "id", "name", "age" FROM "users")) EXCEPT ((SELECT "id", "name", "age" FROM "users") EXCEPT (SELECT "id", "name", "age" FROM "users"))')   }
    its(:to_subquery) { should eql('(((SELECT "id", "name", "age" FROM "users") EXCEPT (SELECT "id", "name", "age" FROM "users")) EXCEPT ((SELECT "id", "name", "age" FROM "users") EXCEPT (SELECT "id", "name", "age" FROM "users")))') }
  end

  context 'when the operands are intersections' do
    let(:operand) { base_relation.intersect(base_relation) }

    it_should_behave_like 'a generated SQL SELECT query'

    its(:to_s)        { should eql('((SELECT "id", "name", "age" FROM "users") INTERSECT (SELECT "id", "name", "age" FROM "users")) EXCEPT ((SELECT "id", "name", "age" FROM "users") INTERSECT (SELECT "id", "name", "age" FROM "users"))')   }
    its(:to_subquery) { should eql('(((SELECT "id", "name", "age" FROM "users") INTERSECT (SELECT "id", "name", "age" FROM "users")) EXCEPT ((SELECT "id", "name", "age" FROM "users") INTERSECT (SELECT "id", "name", "age" FROM "users")))') }
  end

  context 'when the operands are unions' do
    let(:operand) { base_relation.union(base_relation) }

    it_should_behave_like 'a generated SQL SELECT query'

    its(:to_s)        { should eql('((SELECT "id", "name", "age" FROM "users") UNION (SELECT "id", "name", "age" FROM "users")) EXCEPT ((SELECT "id", "name", "age" FROM "users") UNION (SELECT "id", "name", "age" FROM "users"))')   }
    its(:to_subquery) { should eql('(((SELECT "id", "name", "age" FROM "users") UNION (SELECT "id", "name", "age" FROM "users")) EXCEPT ((SELECT "id", "name", "age" FROM "users") UNION (SELECT "id", "name", "age" FROM "users")))') }
  end

  context 'when the operands are joins' do
    let(:operand) { base_relation.join(base_relation) }

    it_should_behave_like 'a generated SQL SELECT query'

    its(:to_s)        { should eql('(SELECT "id", "name", "age" FROM "users" AS "left" NATURAL JOIN "users" AS "right") EXCEPT (SELECT "id", "name", "age" FROM "users" AS "left" NATURAL JOIN "users" AS "right")')   }
    its(:to_subquery) { should eql('((SELECT "id", "name", "age" FROM "users" AS "left" NATURAL JOIN "users" AS "right") EXCEPT (SELECT "id", "name", "age" FROM "users" AS "left" NATURAL JOIN "users" AS "right"))') }
  end

  context 'when the operands have different base relations' do
    let(:relation_name) { 'users_others'                             }
    let(:left)          { Relation::Base.new('users',  header, body) }
    let(:right)         { Relation::Base.new('others', header, body) }

    it_should_behave_like 'a generated SQL SELECT query'

    its(:to_s)        { should eql('(SELECT "id", "name", "age" FROM "users") EXCEPT (SELECT "id", "name", "age" FROM "others")')   }
    its(:to_subquery) { should eql('((SELECT "id", "name", "age" FROM "users") EXCEPT (SELECT "id", "name", "age" FROM "others"))') }
  end

  context 'when the operands have headers sorted in different orders' do
    let(:left)  { Relation::Base.new(relation_name, header,         body) }
    let(:right) { Relation::Base.new(relation_name, header.reverse, body) }

    it_should_behave_like 'a generated SQL SELECT query'

    its(:to_s)        { should eql('(SELECT "id", "name", "age" FROM "users") EXCEPT (SELECT DISTINCT "id", "name", "age" FROM "users")')   }
    its(:to_subquery) { should eql('((SELECT "id", "name", "age" FROM "users") EXCEPT (SELECT DISTINCT "id", "name", "age" FROM "users"))') }
  end
end
