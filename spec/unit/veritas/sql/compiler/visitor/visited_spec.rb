require 'spec_helper'

describe Visitor, '#visited?' do
  subject { object.visited? }

  let(:klass)     { Visitor   }
  let(:object)    { klass.new }

  specify { expect { subject }.to raise_error(NotImplementedError, "#{klass}#visited? must be implemented") }
end
