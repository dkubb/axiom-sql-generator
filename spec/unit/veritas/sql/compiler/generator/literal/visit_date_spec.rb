require 'spec_helper'

describe SQL::Compiler::Generator::Literal, '#visit_date' do
  subject { object.visit_date(date) }

  let(:described_class) { Class.new(SQL::Compiler::Visitor) { include SQL::Compiler::Generator::Literal } }
  let(:date)            { Date.new(2010, 12, 31).freeze                                                   }
  let(:object)          { described_class.new                                                             }

  it_should_behave_like 'a generated SQL expression'

  its(:to_s) { should eql("'2010-12-31'") }
end
