require 'spec_helper'

describe SQL::Compiler::Generator::Literal, '#visit_class' do
  subject { object.visit_class(klass) }

  let(:described_class) { Class.new(SQL::Compiler::Visitor) { include SQL::Compiler::Generator::Literal } }
  let(:object)          { described_class.new                                                             }

  before do
    Object.class_eval { remove_const(:NamedClass) if const_defined?(:NamedClass)  }
    class ::NamedClass; end
  end

  context 'with a named class' do
    let(:klass) { NamedClass.freeze }

    it_should_behave_like 'a generated SQL expression'

    its(:to_s) { should eql("'NamedClass'") }
  end

  context 'with an anonymous class' do
    let(:klass) { described_class }

    it_should_behave_like 'a generated SQL expression'

    its(:to_s) { should eql('NULL') }
  end
end
