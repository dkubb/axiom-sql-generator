# encoding: utf-8

require 'spec_helper'

describe SQL::Compiler::Generator::Relation, '#name' do
  subject { object.name }

  let(:described_class) { Class.new(SQL::Compiler::Generator::Relation) }
  let(:object)          { described_class.new                           }

  context 'when name is nil' do
    it_should_behave_like 'an idempotent method'

    it { should be_nil }
  end

  context 'when name is set' do
    let(:name) { 'test' }

    before do
      # subclasses set @name, but nothing in this class
      # does does so simulate it being set
      object.instance_variable_set(:@name, name)
    end

    it_should_behave_like 'an idempotent method'

    it { should equal(name) }
  end
end
