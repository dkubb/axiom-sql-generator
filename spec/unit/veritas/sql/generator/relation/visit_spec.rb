# encoding: utf-8

require 'spec_helper'

describe SQL::Generator::Relation, '#visit' do
  subject { object.visit(visitable) }

  let(:described_class) { Class.new(SQL::Generator::Relation) }
  let(:object)          { described_class.new                 }

  context 'with a handled object' do
    let(:visitable) { mock('Visitable') }

    before do
      described_class.class_eval do
        def visit_spec_mocks_mock(mock)
          mock
        end
      end
    end

    it_should_behave_like 'a command method'

    specify { expect { subject }.to change(object, :frozen?).from(false).to(true) }
  end

  context 'with a handled object more than once' do
    let(:visitable) { mock('Visitable') }

    before do
      described_class.class_eval do
        def visit_spec_mocks_mock(mock)
          mock
        end
      end
    end

    before do
      object.visit(visitable)
    end

    if RUBY_VERSION >= '1.9'
      specify { expect { subject }.to raise_error(RuntimeError) }
    else
      specify { expect { subject }.to raise_error(TypeError) }
    end
  end

  context 'with an unhandled object' do
    let(:visitable) { mock('Not Handled') }

    specify { expect { subject }.to raise_error(SQL::Generator::Visitor::UnknownObject, "No handler for #{visitable.class} in #{object.class}") }
  end
end
