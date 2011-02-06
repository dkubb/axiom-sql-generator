require 'spec_helper'

describe Generator, '#visit' do
  subject { object.visit(visitable) }

  let(:object) { described_class.new }

  context 'with a handled object' do
    let(:header)    { [ [ :id, Integer ] ]                    }
    let(:body)      { [ [ 1 ] ].each                          }
    let(:visitable) { BaseRelation.new('users', header, body) }

    it_should_behave_like 'a command method'

    specify { expect { subject }.to change(object, :frozen?).from(false).to(true) }
  end

  context 'with a handled object more than once' do
    let(:header)    { [ [ :id, Integer ] ]                    }
    let(:body)      { [ [ 1 ] ].each                          }
    let(:visitable) { BaseRelation.new('users', header, body) }

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

    specify { expect { subject }.to raise_error(Visitor::UnknownObject, "No handler for #{visitable.class}") }
  end
end
