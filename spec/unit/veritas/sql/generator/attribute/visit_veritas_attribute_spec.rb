# encoding: utf-8

require 'spec_helper'

describe SQL::Generator::Attribute, '#visit_veritas_attribute' do
  subject { object.visit_veritas_attribute(attribute) }

  let(:described_class) { Class.new(SQL::Generator::Visitor) { include SQL::Generator::Attribute } }
  let(:attribute)       { Attribute::Integer.new(:id)                                              }
  let(:object)          { described_class.new                                                      }

  it_should_behave_like 'a generated SQL expression'

  its(:to_s) { should eql('"id"') }
end
