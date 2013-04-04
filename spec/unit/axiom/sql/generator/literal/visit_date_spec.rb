# encoding: utf-8

require 'spec_helper'

describe SQL::Generator::Literal, '#visit_date' do
  subject { object.visit_date(date) }

  let(:described_class) { Class.new(SQL::Generator::Visitor) { include SQL::Generator::Literal } }
  let(:date)            { Date.new(2010, 12, 31).freeze                                          }
  let(:object)          { described_class.new                                                    }

  it_should_behave_like 'a generated SQL expression'

  its(:to_s) { should eql("'2010-12-31'") }
end
