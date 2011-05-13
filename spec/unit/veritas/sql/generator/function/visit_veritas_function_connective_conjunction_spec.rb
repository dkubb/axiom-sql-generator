# encoding: utf-8

require 'spec_helper'

describe SQL::Generator::Function, '#visit_veritas_function_connective_conjunction' do
  subject { object.visit_veritas_function_connective_conjunction(conjunction) }

  let(:described_class) { Class.new(SQL::Generator::Visitor) { include SQL::Generator::Function } }
  let(:attribute)       { Attribute::Integer.new(:id)                                             }
  let(:conjunction)     { attribute.eq(1).and(attribute.ne(2))                                    }
  let(:object)          { described_class.new                                                     }

  it_should_behave_like 'a generated SQL expression'

  its(:to_s) { should eql('("id" = 1 AND "id" <> 2)') }
end
