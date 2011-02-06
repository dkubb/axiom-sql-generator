require 'spec_helper'

describe Visitor, '#visit' do
  subject { object.visit(visitable) }

  let(:visitable) { mock('handled object') }
  let(:object)    { described_class.new    }

  specify { expect { subject }.to raise_error(NotImplementedError, "#{described_class}#visit must be implemented") }
end
