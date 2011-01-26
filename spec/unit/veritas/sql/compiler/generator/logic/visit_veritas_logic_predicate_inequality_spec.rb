require 'spec_helper'

describe Generator::Logic, '#visit_veritas_logic_predicate_inequality' do
  subject { object.visit_veritas_logic_predicate_inequality(inequality) }

  let(:klass)  { Class.new(Visitor) { include Generator::Logic } }
  let(:object) { klass.new                                       }

  before do
    object.instance_variable_set(:@name, 'users')
  end

  context 'and the left attribute is optional' do
    let(:attribute)  { Attribute::Integer.new(:age, :required => false) }
    let(:inequality) { attribute.ne(1)                                  }

    it_should_behave_like 'a generated SQL expression'

    it { should == '("users"."age" <> 1 OR "users"."age" IS NULL)' }
  end

  context 'and the right attribute is optional' do
    let(:attribute)  { Attribute::Integer.new(:age, :required => false) }
    let(:inequality) { Logic::Predicate::Inequality.new(1, attribute)   }

    it_should_behave_like 'a generated SQL expression'

    it { should == '(1 <> "users"."age" OR "users"."age" IS NULL)' }
  end

  context 'and the left is a value' do
    let(:attribute)  { Attribute::Integer.new(:id)                    }
    let(:inequality) { Logic::Predicate::Inequality.new(1, attribute) }

    it_should_behave_like 'a generated SQL expression'

    it { should == '1 <> "users"."id"' }
  end

  context 'and the right is a value' do
    let(:attribute)  { Attribute::Integer.new(:id) }
    let(:inequality) { attribute.eq(1)             }

    it_should_behave_like 'a generated SQL expression'

    it { should == '"users"."id" <> 1' }
  end

  context 'and the right is a nil value' do
    let(:attribute)  { Attribute::Integer.new(:id) }
    let(:inequality) { attribute.eq(nil)           }

    it_should_behave_like 'a generated SQL expression'

    it { should == '"users"."id" IS NOT NULL' }
  end
end
