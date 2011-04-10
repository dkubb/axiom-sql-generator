# encoding: utf-8

require 'spec_helper'

describe SQL::Generator::Logic, '#visit_veritas_logic_predicate_inequality' do
  subject { object.visit_veritas_logic_predicate_inequality(inequality) }

  let(:described_class) { Class.new(SQL::Generator::Visitor) { include SQL::Generator::Logic } }
  let(:object)          { described_class.new                                                  }

  context 'and the left attribute is optional' do
    let(:attribute)  { Attribute::Integer.new(:age, :required => false) }
    let(:inequality) { attribute.ne(1)                                  }

    it_should_behave_like 'a generated SQL expression'

    its(:to_s) { should eql('("age" <> 1 OR "age" IS NULL)') }
  end

  context 'and the right attribute is optional' do
    let(:attribute)  { Attribute::Integer.new(:age, :required => false) }
    let(:inequality) { Logic::Predicate::Inequality.new(1, attribute)   }

    it_should_behave_like 'a generated SQL expression'

    its(:to_s) { should eql('(1 <> "age" OR "age" IS NULL)') }
  end

  context 'and the left is a value' do
    let(:attribute)  { Attribute::Integer.new(:id)                    }
    let(:inequality) { Logic::Predicate::Inequality.new(1, attribute) }

    it_should_behave_like 'a generated SQL expression'

    its(:to_s) { should eql('1 <> "id"') }
  end

  context 'and the right is a value' do
    let(:attribute)  { Attribute::Integer.new(:id) }
    let(:inequality) { attribute.ne(1)             }

    it_should_behave_like 'a generated SQL expression'

    its(:to_s) { should eql('"id" <> 1') }
  end

  context 'and the right is a nil value' do
    let(:attribute)  { Attribute::Integer.new(:id) }
    let(:inequality) { attribute.ne(nil)           }

    it_should_behave_like 'a generated SQL expression'

    its(:to_s) { should eql('"id" IS NOT NULL') }
  end
end
