require 'spec_helper'

describe Generator::Literal, '#visit_class' do
  subject { object.visit_class(klass_arg) }

  let(:klass)  { Class.new(Visitor) { include Generator::Literal } }
  let(:object) { klass.new                                         }

  context 'with a named class' do
    let(:klass_arg) { Visitor }

    it_should_behave_like 'a generated SQL expression'

    it { should == "'Veritas::SQL::Compiler::Visitor'" }
  end

  context 'with an anonymous class' do
    let(:klass_arg) { klass }

    it_should_behave_like 'a generated SQL expression'

    it { should == 'NULL' }
  end
end
