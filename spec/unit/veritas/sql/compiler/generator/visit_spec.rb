require 'spec_helper'

describe Generator, '#visit' do
  subject { object.visit(visitable) }

  let(:klass)     { Generator         }
  let(:visitable) { mock('Visitable') }
  let(:object)    { klass.new         }

  it_should_behave_like 'a command method'
end
