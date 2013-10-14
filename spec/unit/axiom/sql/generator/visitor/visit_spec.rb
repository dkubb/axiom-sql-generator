# encoding: utf-8

require 'spec_helper'

describe SQL::Generator::Visitor, '#visit' do
  subject { object.visit(visitable) }

  let(:visitable) { double('handled object') }
  let(:object)    { described_class.new      }

  specify { expect { subject }.to raise_error(NotImplementedError, "#{described_class}#visit must be implemented") }
end
