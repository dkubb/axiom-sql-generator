# encoding: utf-8

require 'spec_helper'

describe SQL::Generator::Literal, '#visit_enumerable' do
  subject { object.visit_enumerable(enumerable) }

  let(:described_class) { Class.new(SQL::Generator::Visitor) { include SQL::Generator::Literal } }
  let(:enumerable)      { [1, 2].freeze                                                          }
  let(:object)          { described_class.new                                                    }

  it_should_behave_like 'a generated SQL expression'

  its(:to_s) { should eql('(1, 2)') }
end
