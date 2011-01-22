require 'spec_helper'

describe Generator::UnaryRelation, '#==' do
  subject { object == other }

  let(:klass)         { Class.new(Visitor) { include Generator::UnaryRelation } }
  let(:id)            { Attribute::Integer.new(:id)                             }
  let(:name)          { Attribute::String.new(:name)                            }
  let(:age)           { Attribute::Integer.new(:age, :required => false)        }
  let(:header)        { [ id, name, age ]                                       }
  let(:body)          { [ [ 1, 'Dan Kubb', 35 ] ].each                          }
  let(:base_relation) { BaseRelation.new('users', header, body)                 }
  let(:object)        { klass.new                                               }

  before do
    object.visit_veritas_base_relation(base_relation)
  end

  context 'with the same object' do
    let(:other) { object }

    it { should be(true) }

    it 'is symmetric' do
      should == (other == object)
    end
  end

  context 'with an equivalent object' do
    let(:other) { object.dup }

    it { should be(true) }

    it 'is symmetric' do
      should == (other == object)
    end
  end

  context 'with an equivalent object of a subclass' do
    let(:other) { Class.new(klass).new }

    before do
      other.visit_veritas_base_relation(base_relation)
    end

    it { should be(true) }

    it 'is symmetric' do
      should == (other == object)
    end
  end

  context 'with an object having visited a different object' do
    let(:other) { klass.new }

    before do
      other.visit_veritas_algebra_projection(base_relation.project([ :id ]))
    end

    it { should be(false) }

    it 'is symmetric' do
      should == (other == object)
    end
  end
end
