# encoding: utf-8

require 'spec_helper'

describe SQL::Compiler::Visitor, '#visited?' do
  subject { object.visited? }

  let(:object) { described_class.new }

  specify { expect { subject }.to raise_error(NotImplementedError, "#{described_class}#visited? must be implemented") }
end
