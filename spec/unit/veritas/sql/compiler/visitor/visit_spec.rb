require 'spec_helper'

describe Visitor, '#visit' do
  subject { object.visit(visitable) }

  let(:klass)     { Visitor                }
  let(:visitable) { mock('handled object') }
  let(:object)    { klass.new              }

  specify { expect { subject }.to raise_error(NotImplementedError, "#{klass}#visit must be implemented") }
end
