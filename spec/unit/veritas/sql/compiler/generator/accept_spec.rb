require 'spec_helper'

describe Generator, '#accept' do
  subject { object.accept(visitable) }

  let(:klass)     { Generator         }
  let(:visitable) { mock('Visitable') }
  let(:object)    { klass.new         }

  it { should equal(object) }
end
